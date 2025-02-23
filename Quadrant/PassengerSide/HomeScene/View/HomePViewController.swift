//
//  HomePViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/14/21.
//133972

import UIKit
import RxCocoa
import RxSwift
import SideMenuSwift
import MapKit
import CoreLocation
import UserNotifications
import TTGSnackbar

class HomePViewController: UIViewController {

    //MARK: - View Outlets
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var whereButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var closeBottomViewButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var driverInformationsView: UIView!
    @IBOutlet weak var driverStateLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var callButton: UIButton!
    
    var user: User?
    var currentTrip: Trip?
    
    private let bag = DisposeBag()
    private var viewModel = HomePViewModel()
    static let locationManager = CLLocationManager()
    
    private var snackbar = TTGSnackbar()
    private var selectedPlaceMark: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeAllPreviousVCInNavigationStack()
        viewModel.fetchUser()
        configureUI()
        setupLocationManager()
        configureSideMenu()
        whereButtonTapped()
        actionButtonTapped()
        callButtonTapped()
        sideMenuButtonTapped()
        closeBottomViewButtonTapped()
        bindViewModelData()
        addNotificationCenterObservers()
        addPanGesture()
        setupReachability()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Reachability
    private func setupReachability() {
        
        ReachabilityManager.shared.isConnectedObservable.subscribe(onNext: { [weak self] isConnected in
            guard let self = self else { return }
            if isConnected {
                self.snackbar.dismiss()
                guard self.snackbar.messageLabel.text == "No Internet Connection" else { return }
                self.snackbar = self.createTTGSnackBar(message: "Connected Successfully", icon: UIImage(named: "Material_Check_Circle")!, color: UIColor.systemGreen, duration: .middle)
                self.snackbar.show()
            } else {
                self.snackbar.dismiss()
                self.snackbar = self.createTTGSnackBar(message: "No Internet Connection", icon: UIImage(named: "Material_Cancel")!, color: UIColor.systemRed, duration: .forever)
                self.snackbar.show()
            }
        }).disposed(by: bag)
    }
    
    //MARK: - UI Configurations
    private func configureUI() {
        whereButton.layer.cornerRadius = whereButton.frame.height / 2
        requestButton.layer.cornerRadius = requestButton.frame.height / 2
        bottomViewHeight.constant = 0
        
        bottomView.layer.cornerRadius = 25
        bottomView.layer.shadowOpacity = 1
        bottomView.layer.shadowOffset = CGSize(width: 10, height: 10)
        bottomView.layer.shadowRadius = 20

    }

    private func configureSideMenu() {
        SideMenuController.preferences.basic.menuWidth = self.view.frame.width/4 * 3
        SideMenuController.preferences.basic.position = .sideBySide
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
        SideMenuController.preferences.animation.shadowColor = UIColor.black
        SideMenuController.preferences.animation.shadowAlpha = 0.5
    }
    
    func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveBottomView(_:)))
        bottomView.addGestureRecognizer(pan)
    }
    
    
    //MARK: - View Model Binding
    private func bindViewModelData() {
        
        viewModel.isSignedOut.subscribe(onNext: { [weak self] isSignedOut in
            if isSignedOut {
                let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
                self?.navigationController?.pushViewController(loginVC!, animated: true)
            }
        }).disposed(by: bag)
        
        viewModel.routeObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] route in
                guard route != nil else {
                    self?.distanceLabel.text = "--"
                    self?.priceLabel.text = "--"
                    self?.timeLabel.text = "--"
                    return
                }
                self?.mapView.addOverlay(route!.polyline)
                self?.distanceLabel.text = String(format: "%.1f", (route!.distance / 1000)) + " KM"
                self?.priceLabel.text = String(format: "%.1f", ((route!.distance / 1000) * 3 + 15)) + " EGP"
                self?.timeLabel.text = String(format: "%.1f", ((route!.expectedTravelTime / 60) + 5)) + " MINUTES"
            }).disposed(by: bag)
        
        viewModel.polylineObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] polyline in
                self?.mapView.addOverlay(polyline)
            }).disposed(by: bag)
        
        viewModel.userObservable.subscribe(onNext: { [weak self] user in
            self?.user = user
        }).disposed(by: bag)
        
        viewModel.currentTripObservable.subscribe(onNext: { [weak self] trip in
            guard let self = self else { return }
            self.currentTrip = trip
            switch trip.tripState {
            case .requested:
                self.showHUD(message: "We are finding you a ride, please wait...")
                self.currentTrip = trip
            case .waitingToAccept:
                break
            case .accepted:
                self.tripAccepted(trip: trip)
            case .rejected:
                self.closeBottomView()
                self.showAlertSheet(title: "Ops!", message: "The Driver Didn't Accept your request, Please try again...")
                if let driverUID = trip.driverUID , !driverUID.isEmpty  {
                    REF_DRIVER_LOCATION.child(driverUID).removeAllObservers()
                }
            case .driverArrived:
                self.driverArrived()
            case .inProgress:
                self.tripInProgress(trip: trip)
            case .arriverAtDestination:
                self.arrivedAtDestination(trip: trip)
            case .completed:
                break
            case .none:
                break
            }
        }).disposed(by: bag)
    }
    
    //MARK: - Buttons Configurations
    private func whereButtonTapped() {
        whereButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let vc = UIStoryboard(name: "LocationInput", bundle: nil).instantiateInitialViewController() as? LocationInputViewController

            vc?.selectedPlaceMarkBehavior
                .filter({ $0 != nil })
                .subscribe(onNext: { placeMark in
                    self.selectedPlaceMark = placeMark
                    self.selectedPlaceShowDetails(place: placeMark!)
                }).disposed(by: self.bag)

            vc?.modalPresentationStyle = .popover
            self.present(vc!, animated: true)
        }).disposed(by: bag)
    }
    
    private func sideMenuButtonTapped() {
        sideMenuButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.sideMenuController?.revealMenu()
        }).disposed(by: bag)
    }
    
    private func closeBottomViewButtonTapped() {
        closeBottomViewButton.rx.tap.subscribe(onNext: { [weak self] in
            let alert = UIAlertController(title: "Cancel Trip", message: "Do you really want to cancel the trip?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "YES", style: .default) { _ in
                self?.closeBottomView()
                if let driverUID = self?.currentTrip?.driverUID, !driverUID.isEmpty {
                    REF_DRIVER_LOCATION.child(driverUID).removeAllObservers()
                }
            }
            let action2 = UIAlertAction(title: "NO", style: .cancel, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
            self?.present(alert, animated: true)
            
        }).disposed(by: bag)
    }
    
    private func actionButtonTapped() {
        requestButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.requestTrip()
        }).disposed(by: bag)
    }
    
    private func callButtonTapped() {
        callButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let driverPhoneNumber = self?.currentTrip?.driverPhoneNumber else { return }
            self?.call(number: driverPhoneNumber)
        }).disposed(by: bag)
        
    }
    
    
    
    //MARK: - UIPanGesture
    @objc func moveBottomView( _ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let yTranslate = gesture.translation(in: bottomView).y
            UIView.animate(withDuration: 0) {
                self.bottomViewHeight.constant = self.bottomViewHeight.constant - yTranslate
                gesture.setTranslation(.zero, in: self.bottomView)
            }
        case .ended:
            if self.bottomViewHeight.constant > self.view.frame.height / 2 || self.bottomViewHeight.constant < 100 {
                UIView.animate(withDuration: 0.5) {
                    self.bottomViewHeight.constant = 200
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
    
    //MARK: - Trip Life Cycle Helper Functions
    private func selectedPlaceShowDetails(place: MKPlacemark) {
        
        sideMenuButton.alpha = 0
        whereButton.alpha = 0
        requestButton.alpha = 1
        callButton.alpha = 0
        driverInformationsView.alpha = 0
        closeBottomViewButton.alpha = 1
        
        let name = place.name
        let thoroughFare = place.thoroughfare
        let subThoroughFare = place.subThoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        destinationLabel.text = "\(name ?? "") \(thoroughFare ?? "") \(subThoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn) {
            self.bottomViewHeight.constant = 220
            self.view.layoutIfNeeded()
        }
        mapView.addAndSelectAnnotation(coordinate: place.coordinate)
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKUserLocation.self) || $0.isKind(of: MKPointAnnotation.self) })
        mapView.fitAll(in: zoomInAnnotations, andShow: true)
        viewModel.showRoute(destination: place, locationManager: HomePViewController.locationManager)
    }
    
    private func requestTrip() {
        guard let pickup = HomePViewController.locationManager.location?.coordinate else { return }
        viewModel.uploadTrip(pickup: pickup, destinationPlace: selectedPlaceMark!, user: user!)
        viewModel.observeCurrentTripState()
        requestButton.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn) {
            self.bottomViewHeight.constant = 170
            self.view.layoutIfNeeded()
        }
    }
    
    private func closeBottomView() {
        dismissHUD()
        if let driverUID = currentTrip?.driverUID , !driverUID.isEmpty {
            REF_DRIVER_LOCATION.child(driverUID).removeAllObservers()
        }
        viewModel.removeObserverAndValueTrip()
        mapView.removeAnnotationAndOverlays()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        mapView.centerMapOnUser()
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
            self.whereButton.alpha = 1
            self.sideMenuButton.alpha = 1
            self.bottomViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    
    private func tripAccepted(trip: Trip) {
        dismissHUD()
        callButton.alpha = 1
        driverInformationsView.alpha = 1
        driverNameLabel.text = trip.driverName
        driverStateLabel.text = "Driver En Route"
        let firstChar = trip.driverName!.first!.lowercased()
        self.driverImageView.image = UIImage(named: "SF_\(firstChar)_circle")
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn) {
            self.bottomViewHeight.constant = 280
            self.view.layoutIfNeeded()
        }
        
        mapView.removeAnnotationAndOverlays()
        viewModel.driverLocationLive(uid: trip.driverUID!, mapView: mapView, completion: {
            let zoomInAnnotations = self.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self) || $0.isKind(of: MKUserLocation.self) })
            self.mapView.fitAll(in: zoomInAnnotations, andShow: true)
        })
        viewModel.getDriverLocation(uid: trip.driverUID!) { driverPlace in
            self.viewModel.showPolyline(destination: driverPlace, locationManager: HomePViewController.locationManager)
        }
        
        
    }
    
    private func driverArrived() {
        self.sendNotification(body: "Your Driver Has Arrived")
        driverStateLabel.text = "The Driver has arrived, Please meet Him at Pickup Location"
    }
    
    private func tripInProgress(trip: Trip) {
        callButton.alpha = 0
        closeBottomViewButton.alpha = 0
        REF_DRIVER_LOCATION.child(trip.driverUID!).removeAllObservers()
        mapView.removeAnnotationAndOverlays()
        mapView.addAndSelectAnnotation(coordinate: trip.destinationCoordinates)
        
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKUserLocation.self) || $0.isKind(of: MKPointAnnotation.self) })
        mapView.fitAll(in: zoomInAnnotations, andShow: true)
        viewModel.showPolyline(destination: MKPlacemark(coordinate: trip.destinationCoordinates), locationManager: HomePViewController.locationManager)
        driverStateLabel.text = "En Route To Destination"
    }
    
    private func arrivedAtDestination(trip: Trip) {
        viewModel.saveCompletedTrip(trip: trip)
        closeBottomView()
        showAlertSheet(title: "Arrived at Destination Location", message: "We hope you had an Enjoyable Ride!")
    }
    
    
    private func showAlertSheet(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func call(number: String) {
        guard let number = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(number)
    }
    
    // MARK: - Navigation and Side Menu Controllers
    private func addNotificationCenterObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: "SignoutP"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToSettingsPController), name: NSNotification.Name(rawValue: "SettingsP"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToYourTripsPController), name: NSNotification.Name(rawValue: "YourTripsP"), object: nil)
    }
    
    @objc func goToYourTripsPController() {
        let yourTripsVC = UIStoryboard(name: "YourTripsP", bundle: nil).instantiateInitialViewController()
        yourTripsVC?.title = "Completed Trips"
        self.navigationController?.pushViewController(yourTripsVC!, animated: true)
    }
    
    @objc func goToSettingsPController() {
        let settingsVC = UIStoryboard(name: "SettingsP", bundle: nil).instantiateInitialViewController()
        settingsVC?.title = "Settings"
        self.navigationController?.pushViewController(settingsVC!, animated: true)
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Sign out", message: "Do you really want to sign out?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Sign out", style: .destructive) { _ in
            self.viewModel.signOut()
        }
        let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    

}

//MARK: - Location Manager Delegate
extension HomePViewController: CLLocationManagerDelegate {
    
    private func setupLocationManager() {
        HomePViewController.locationManager.delegate = self
        HomePViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 14.0, *) {
            
        } else {
            HomePViewController.locationManager.requestWhenInUseAuthorization()
            HomePViewController.locationManager.startUpdatingLocation()
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        
        case .notDetermined:
            HomePViewController.locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            HomePViewController.locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            HomePViewController.locationManager.startUpdatingLocation()
            break
        case .restricted:
            break
        case .denied:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let passengerLocation = locations.first else { return}
        configureMapView(location: passengerLocation)
        HomePViewController.locationManager.stopUpdatingLocation()
    }
        
    
}

//MARK: - MKMap View Delegate
extension HomePViewController: MKMapViewDelegate {
    
    // Called when location did update
    func configureMapView(location: CLLocation) {
        mapView.delegate = self
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(rgb: 0xEB0000)
        renderer.lineWidth = 5.0
        renderer.alpha = 0.5
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnnotation")
            annotationView.image = #imageLiteral(resourceName: "icons8-car_top_view")
            return annotationView
        }
        
        if #available(iOS 14.0, *), annotation is MKUserLocation {
            let reuseIdentifier = "userLocation"
            if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
                return existingView
            }
            let view = MKUserLocationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view.zPriority = .max
            view.isEnabled = false
            return view
        }
        
        return nil
    }
    
    
}

//MARK: - Local Notifications
extension HomePViewController: UNUserNotificationCenterDelegate {
    
    func sendNotification(body: String) {
        let nContent = UNMutableNotificationContent()
        nContent.title = "Your Trip"
        nContent.body = body
        nContent.badge = 1
        nContent.sound = .default
        let date = Date().addingTimeInterval(0.5)
        let dateComp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier,
                                            content: nContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (err) in
            if let err = err {
                print(err)
            }
        }
    }
    
    
    
}


