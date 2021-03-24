//
//  HomeDViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/16/21.
//

import UIKit
import MapKit
import CoreLocation
import SideMenuSwift
import RxCocoa
import RxSwift

class HomeDViewController: UIViewController {
    
    
    //MARK: - View Outlets
    @IBOutlet weak var dropoffPassengerButton: UIButton!
    @IBOutlet weak var cancelTripButton: UIButton!
    @IBOutlet weak var pickupPassengerButton: UIButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var passengerNameLabel: UILabel!
    @IBOutlet weak var passengerStateLabel: UILabel!
    @IBOutlet weak var passengerImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var searchButton: LoadingButton!
    
    var user: User?
    var currentTrip: Trip?
    
    private let bag = DisposeBag()
    private var viewModel = HomeDViewModel()
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeAllPreviousVCInNavigationStack()
        viewModel.fetchUser()
        configureUI()
        configureSideMenu()
        setupLocationManager()
        sideMenuButtonTapped()
        searchButtonTapped()
        bindViewModelData()
        pickupPassengerButtonTapped()
        cancelTripButtonTapped()
        dropoffPassengerButtonTapped()
        addNotificationCenterObservers()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - UI Configurations
    private func configureUI() {
        searchButton.layer.cornerRadius = searchButton.frame.height / 2
        pickupPassengerButton.layer.cornerRadius = 10
        dropoffPassengerButton.layer.cornerRadius = 10
        bottomViewHeight.constant = 0
        
        passengerStateLabel.adjustsFontSizeToFitWidth = true
        
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
    
    //MARK: - Buttons Configurations
    private func sideMenuButtonTapped() {
        sideMenuButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.sideMenuController?.revealMenu()
        }).disposed(by: bag)
    }
    
    private func pickupPassengerButtonTapped() {
        pickupPassengerButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.passengerDidEnterStartTrip()
        }).disposed(by: bag)
    }
    
    private func cancelTripButtonTapped() {
        cancelTripButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            REF_TRIPS.child(self.currentTrip!.passengerUID).removeAllObservers()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.bottomViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            self.searchButton.tag = 0
            self.searchButton.hideLoading()
            self.mapView.removeAnnotationAndOverlays()
            self.mapView.centerMapOnUser()
            self.viewModel.updateTripState(uid: self.currentTrip!.passengerUID, state: .rejected)
        }).disposed(by: bag)
    }
    
    private func searchButtonTapped() {
        searchButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.searchButton.tag == 0 {
                self.searchButton.tag = 1
                self.searchButton.showLoading()
                self.viewModel.fetchTrip()
                print("Start Fetching trips")
            } else {
                self.searchButton.tag = 0
                self.searchButton.hideLoading()
                REF_TRIPS.removeAllObservers()
                print("Stop Fetching")
            }
        }).disposed(by: bag)
    }
    
    private func dropoffPassengerButtonTapped() {
        dropoffPassengerButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.arrivedAtDestinationLocation()
            self?.showAlertSheet(title: "Trip Completed", message: "You Dropped off The Passenger at the required location... Thank You for the Ride!")

        }).disposed(by: bag)
    }
    
    
    //MARK: - ViewModel Binding
    private func bindViewModelData() {
        
        viewModel.isSignedOut.subscribe(onNext: { [weak self] isSignedOut in
            if isSignedOut {
                let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
                self?.navigationController?.pushViewController(loginVC!, animated: true)
            }
        }).disposed(by: bag)
        
        viewModel.polylineObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] polyline in
                self?.mapView.addOverlay(polyline)
            }).disposed(by: bag)
        
        viewModel.userObservable.subscribe(onNext: { [weak self] user in
            self?.user = user
        }).disposed(by: bag)
        
        viewModel.tripObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] trip in
                self?.goToPickupController(trip: trip)
            }).disposed(by: bag)
        
        viewModel.isTheTripCanceledBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isTheTripCanceled in
                if isTheTripCanceled {
                    self?.passengerDidCancelTrip()
                }
            }).disposed(by: bag)
        
    }
    
    //MARK: - Trip LifeCycle Functions
    private func goToPickupController(trip: Trip) {
        let pickupVC = UIStoryboard(name: "Pickup", bundle: nil).instantiateInitialViewController() as? PickupViewController
        pickupVC?.trip = trip
        pickupVC?.driverUser = self.user
        pickupVC?.modalPresentationStyle = .fullScreen
        
        pickupVC?.isCanceledBehavior
            .subscribe(onNext: { [weak self] isCanceled in
                if isCanceled {
                    self?.searchButton.tag = 0
                    self?.searchButton.hideLoading()
                    self?.showAlertSheet(title: "Ops!", message: "The Passeneger canceled the Trip")
                    REF_TRIPS.child(trip.passengerUID).removeAllObservers()
                }
            }).disposed(by: bag)
        
        pickupVC?.isRejectedBehavior
            .subscribe(onNext: { [weak self] isRejected in
                if isRejected {
                    REF_TRIPS.child(trip.passengerUID).removeAllObservers()
                    self?.searchButton.tag = 0
                    self?.searchButton.hideLoading()
                }
            }).disposed(by: bag)
        
        pickupVC?.isAcceptedBehavior
            .filter({ $0 != nil })
            .subscribe(onNext: { [weak self] trip in
                self?.currentTrip = trip
                self?.tripAcceptedShowBottomView(trip: trip!)
            }).disposed(by: bag)
        
        self.present(pickupVC!, animated: true)
    }
    
    
    private func tripAcceptedShowBottomView(trip: Trip) {
        viewModel.isTheTripCancled(uid: trip.passengerUID)
        pickupPassengerButton.alpha = 0
        dropoffPassengerButton.alpha = 0
        destinationView.alpha = 0
        cancelTripButton.alpha = 1
        callButton.alpha = 1
        
        
        passengerNameLabel.text = trip.passengerName
        passengerStateLabel.text = "En Route To Passenger"
        let firstChar = trip.passengerName.first!.lowercased()
        self.passengerImageView.image = UIImage(named: "SF_\(firstChar)_circle")
        
        
        UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseIn) {
            self.bottomViewHeight.constant = 180
            self.view.layoutIfNeeded()
        }
        mapView.addAndSelectAnnotation(coordinate: trip.pickupCoordinates)
        viewModel.showPolyline(destinationCoordinations: trip.pickupCoordinates, locationManager: locationManager)
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKPointAnnotation.self) || $0.isKind(of: MKUserLocation.self) })
        mapView.fitAll(in: zoomInAnnotations, andShow: true)
        setCircleRegion(identifier: CircularRegionType.pickup.rawValue, coordinate: trip.pickupCoordinates)
    
    }
    
    private func passengerDidCancelTrip() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.bottomViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }
        self.showAlertSheet(title: "Ops!", message: "The Passenger Canceled The Trip")
        self.searchButton.tag = 0
        self.searchButton.hideLoading()
        mapView.removeAnnotationAndOverlays()
        mapView.centerMapOnUser()
        REF_TRIPS.child(currentTrip!.passengerUID).removeAllObservers()

    }
    
    private func arriverAtPickupLocation() {
        pickupPassengerButton.alpha = 1
        passengerStateLabel.text = "Arrived At Pickup Location\nClick Button When You Pick Up The Passenger"
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.bottomViewHeight.constant = 230
            self.view.layoutIfNeeded()
        }
        
        
        viewModel.updateTripState(uid: currentTrip!.passengerUID, state: .driverArrived)
    }
    
    private func passengerDidEnterStartTrip() {
        viewModel.updateTripState(uid: currentTrip!.passengerUID, state: .inProgress)
        passengerStateLabel.text = "En Route To Destination"
        callButton.alpha = 0
        destinationView.alpha = 1
        destinationAddressLabel.text = currentTrip?.destinationName
        dropoffPassengerButton.alpha = 1
        pickupPassengerButton.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.bottomViewHeight.constant = 300
            self.view.layoutIfNeeded()
        }
        
        mapView.removeAnnotationAndOverlays()
        mapView.addAndSelectAnnotation(coordinate: currentTrip!.destinationCoordinates)
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKPointAnnotation.self) || $0.isKind(of: MKUserLocation.self) })
        mapView.fitAll(in: zoomInAnnotations, andShow: true)
        viewModel.showPolyline(destinationCoordinations: currentTrip!.destinationCoordinates, locationManager: locationManager)
        setCircleRegion(identifier: CircularRegionType.destination.rawValue, coordinate: currentTrip!.destinationCoordinates)
    }
    
    private func arrivedAtDestinationLocation() {
        viewModel.updateTripState(uid: currentTrip!.passengerUID, state: .arriverAtDestination)
        viewModel.saveCompletedTrip(trip: currentTrip!)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.bottomViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }
        self.searchButton.tag = 0
        self.searchButton.hideLoading()
        mapView.removeAnnotationAndOverlays()
        mapView.centerMapOnUser()
        REF_TRIPS.child(currentTrip!.passengerUID).removeAllObservers()
    }
    
    
    private func setCircleRegion(identifier: String, coordinate: CLLocationCoordinate2D) {
        let circleRegion = CLCircularRegion(center: coordinate, radius: 20, identifier: identifier)
        locationManager.startMonitoring(for: circleRegion)
    }
    
    private func showAlertSheet(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Navigation And SideMenu View Controllers
    private func addNotificationCenterObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: "SignoutD"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToSettingsDController), name: NSNotification.Name(rawValue: "SettingsD"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToYourTripsDController), name: NSNotification.Name(rawValue: "YourTripsD"), object: nil)
    }
    
    @objc func goToYourTripsDController() {
        let yourTripsVC = UIStoryboard(name: "YourTripsD", bundle: nil).instantiateInitialViewController()
        yourTripsVC?.title = "Completed Trips"
        self.navigationController?.pushViewController(yourTripsVC!, animated: true)
    }
    
    @objc func goToSettingsDController() {
        let settingsVC = UIStoryboard(name: "SettingsD", bundle: nil).instantiateInitialViewController()
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
extension HomeDViewController: CLLocationManagerDelegate {
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 14.0, *) {
            
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let passengerLocation = locations.first else { return}
        configureMapView(location: passengerLocation)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == CircularRegionType.pickup.rawValue {
            arriverAtPickupLocation()
        } else {
            arrivedAtDestinationLocation()
            showAlertSheet(title: "Done", message: "You Arrived At Destination Location, Please Drop Off The Passenger")
        }
    }
        
    
}

//MARK: - MKMap View Delegate
extension HomeDViewController: MKMapViewDelegate {
    
    // Called when location did update
    func configureMapView(location: CLLocation) {
        mapView.delegate = self
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(rgb: 0xEB0000)
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let location = userLocation.location else { return }
        viewModel.setDriverLocation(location: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
