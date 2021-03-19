//
//  HomePViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/14/21.
//

import UIKit
import RxCocoa
import RxSwift
import SideMenuSwift
import MapKit
import CoreLocation

class HomePViewController: UIViewController {

    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var whereButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var closeBottomViewButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
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
    private let locationManager = CLLocationManager()
    
    private var selectedPlaceMark: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchUser()
        configureUI()
        setupLocationManager()
        configureSideMenu()
        whereButtonTapped()
        actionButtonTapped()
        sideMenuButtonTapped()
        closeBottomViewButtonTapped()
        bindViewModelData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureUI() {
        whereButton.layer.cornerRadius = whereButton.frame.height / 2
        actionButton.layer.cornerRadius = actionButton.frame.height / 2
        closeBottomViewButton.layer.cornerRadius = closeBottomViewButton.frame.height / 2
        bottomViewHeight.constant = 0
        bottomView.layer.cornerRadius = 25
        bottomView.layer.shadowOpacity = 1
        bottomView.layer.shadowOffset = CGSize(width: 10, height: 10)
        bottomView.layer.shadowRadius = 20
        bottomView.layer.shadowColor = UIColor.label.cgColor
        
        actionButton.layer.shadowColor = UIColor.gray.cgColor
        actionButton.layer.shadowOffset = CGSize.zero
        actionButton.layer.shadowOpacity = 1
        actionButton.layer.shadowRadius = 5
        
        closeBottomViewButton.layer.shadowColor = UIColor.gray.cgColor
        closeBottomViewButton.layer.shadowOffset = CGSize.zero
        closeBottomViewButton.layer.shadowOpacity = 1
        closeBottomViewButton.layer.shadowRadius = 5


    }

    private func configureSideMenu() {
        SideMenuController.preferences.basic.menuWidth = self.view.frame.width/4 * 3
        SideMenuController.preferences.basic.position = .sideBySide
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
        SideMenuController.preferences.animation.shadowColor = UIColor.black
        SideMenuController.preferences.animation.shadowAlpha = 0.5
    }
    
    private func selectedPlaceShowDetails(place: MKPlacemark) {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn) {
            self.whereButton.alpha = 0
            self.sideMenuButton.alpha = 0
            self.bottomViewHeight.constant = 300
            self.view.layoutIfNeeded()
        }
        let thoroughFare = place.thoroughfare
        let subThoroughFare = place.subThoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        destinationLabel.text = "\(thoroughFare ?? "") \(subThoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
        destinationLabel.adjustsFontSizeToFitWidth = true
        destinationLabel.minimumScaleFactor = 0.5
        actionButton.alpha = 1
        driverInformationsView.alpha = 0
        mapView.addAndSelectAnnotation(coordinate: place.coordinate)
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKUserLocation.self) || $0.isKind(of: MKPointAnnotation.self) })
        mapView.fitAll(in: zoomInAnnotations, andShow: true)
        viewModel.showRoute(destination: place, locationManager: locationManager)
    }
    
    private func requestTrip() {
        guard let pickup = locationManager.location?.coordinate else { return }
        viewModel.uploadTrip(pickup: pickup, destinationPlace: selectedPlaceMark!, user: user!)
        viewModel.observeCurrentTripState()
        actionButton.alpha = 0
    }
    
    private func closeBottomView() {
        dismissHUD()
        viewModel.removeObserverAndValueTrip()
        if let driverUID = currentTrip?.driverUID {
            REF_DRIVER_LOCATION.child(driverUID).removeAllObservers()
        }
        mapView.removeAnnotationAndOverlays()
        mapView.centerMapOnUser()
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
            self.whereButton.alpha = 1
            self.sideMenuButton.alpha = 1
            self.bottomViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }

    }
    
    private func bindViewModelData() {
        viewModel.routeObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] route in
                self?.mapView.addOverlay(route.polyline)
                self?.distanceLabel.text = String(format: "%.1f", (route.distance / 1000)) + " KM"
                self?.priceLabel.text = String(format: "%.1f", ((route.distance / 1000) * 3 + 15)) + " EGP"
                self?.timeLabel.text = String(format: "%.1f", ((route.expectedTravelTime / 60) + 5)) + " MINUTES"
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
                if let driverUID = trip.driverUID {
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
            self?.closeBottomView()
        }).disposed(by: bag)
    }
    
    private func actionButtonTapped() {
        actionButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.requestTrip()
        }).disposed(by: bag)
    }

    
    private func tripAccepted(trip: Trip) {
        dismissHUD()
        driverInformationsView.alpha = 1
        driverNameLabel.text = trip.driverName
        driverStateLabel.text = "Driver En Route"
        let firstChar = trip.driverName!.first?.lowercased()
        self.driverImageView.image = UIImage(systemName: "\(firstChar!).circle")
        mapView.removeAnnotationAndOverlays()
        viewModel.driverLocationLive(uid: trip.driverUID!, mapView: mapView, completion: {
            let zoomInAnnotations = self.mapView.annotations.filter({ $0.isKind(of: DriverAnnotation.self) || $0.isKind(of: MKUserLocation.self) })
            self.mapView.fitAll(in: zoomInAnnotations, andShow: true)
        })
        
    }
    
    private func driverArrived() {
        driverStateLabel.text = "The Driver has arrived, Please meet Him at Pickup Location"
    }
    
    private func tripInProgress(trip: Trip) {
        REF_DRIVER_LOCATION.child(trip.passengerUID).removeAllObservers()
        mapView.removeAnnotationAndOverlays()
        mapView.addAndSelectAnnotation(coordinate: trip.destinationCoordinates)
        let zoomInAnnotations = mapView.annotations.filter({ $0.isKind(of: MKUserLocation.self) || $0.isKind(of: MKPointAnnotation.self) })
        mapView.fitAll(in: zoomInAnnotations, andShow: true)
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
    
    

}

//MARK: - Location Manager Delegate
extension HomePViewController: CLLocationManagerDelegate {
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
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
        
    
}

//MARK: - MKMap View Delegate
extension HomePViewController: MKMapViewDelegate {
    
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
        renderer.strokeColor = UIColor(hexString: "C90000")
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnnotation")
            annotationView.image = #imageLiteral(resourceName: "icons8-car_top_view")
            return annotationView
        }
        return nil
    }
    
    
}


//      37.33233141
//     -122.0312186
