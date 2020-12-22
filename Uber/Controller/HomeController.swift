//
//  HomeController.swift
//  Uber
//
//  Created by Marwan Osama on 11/23/20.
//

import UIKit
import FirebaseAuth
import MapKit
import CoreLocation



class HomeController: UIViewController {
    
    
    @IBOutlet weak var cornerButton: UIButton!
    @IBOutlet weak var whereToView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rideActionView: UIView!
    @IBOutlet weak var rideActionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
    @IBOutlet weak var confirmRideButton: UIButton!
    @IBOutlet weak var filledCircleLabel: UILabel!
    @IBOutlet weak var uberXLabel: UILabel!
    @IBOutlet weak var searchTripsButton: UIButton!
    
    
    var rideActionViewState : RideActionViewConfiguration = .requested
    var cornerButtonState = CornerButtonConfiguration()
    var zoomInUser: Bool = false
    var zoomInUserAndPoint: Bool = false
    var zoomInUserAndDriver: Bool = false
    let locationManager = MapLocationServices.shared.locationManager
    var selectedPlace: MKPlacemark?
    var acceptedTrip: Trip?

    var userData: User? {
        didSet {
            configurePassengerUI()
            configureDriverUI()
            uploadPassengerLocation()
            uploadDriverLocation()
            currentTripState()
        }
    }
    
    var trip: Trip? {
        didSet {
            self.performSegue(withIdentifier: "PickupController", sender: self)

        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationStatus()
        fetchUserData()
        mapView.delegate = self
        whereToView.alpha = 0
        searchTripsButton.alpha = 0
        
    }
    
    
    func signOut() {
        Authentication.shared.signOut { (isSuccess, err) in
            if let err = err {
                showAlert(title: "ALERT", message: err.localizedDescription)
            }
            // go to Login screen
            let vc: UIViewController = (storyboard?.instantiateViewController(identifier: "LoginController"))!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction.init(title: "ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func configureMapView(location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow

    }
    
    func configureDriverUI() {
        guard userData?.accountType == .driver else {return}
        searchTripsButton.tag = 0
        self.searchTripsButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: 1) {
            self.searchTripsButton.alpha = 1
        }
    }
    
    func configurePassengerUI() {
        guard userData?.accountType == .passenger else {return}
        whereToView.layer.shadowColor = UIColor.label.cgColor
        whereToView.layer.shadowOpacity = 1
        whereToView.layer.shadowOffset = CGSize(width: 0, height: 0)
        whereToView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLocationInputView)))
        UIView.animate(withDuration: 0.5) {
            self.whereToView.alpha = 1
        }
    }
    
    @objc func showLocationInputView() {
        performSegue(withIdentifier: "LocationInputController", sender: self)

    }
    
    // get User Data from Database
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(userID: userID) { (user) in
            self.userData = user
        }
    }

    
    func fetchTrips() {
        guard userData?.accountType == .driver else {return}
        Service.shared.fetchTrip(location: self.locationManager.location!) { (trip) in
            if trip.tripState == .requested {
                print("DEBUG: The Requested trip is \(trip) ")
                self.trip = trip
            }
        }
    }
    
    func uploadPassengerLocation() {
        guard userData?.accountType == .passenger else {return}
        guard let location = self.locationManager.location else {return}
        Service.shared.setPassengerLocation(location: location)
    }
    
    func uploadDriverLocation() {
        guard userData?.accountType == .driver else {return}
        guard let location = self.locationManager.location else {return}
        Service.shared.setDriverLocation(location: location)
    }
    
    func configRideActionView(place: MKPlacemark?, trip: Trip?, config: RideActionViewConfiguration) {
        switch config {
        case.requested:
            guard let thoroughFare = place?.thoroughfare else {return}
            guard let subThoroughFare = place?.subThoroughfare else {return}
            guard let locality = place?.locality else {return}
            guard let adminArea = place?.administrativeArea else {return}
            placeName.text = place?.name
            placeAddress.text = "\(thoroughFare) \(subThoroughFare) \(locality) \(adminArea)"
            placeAddress.adjustsFontSizeToFitWidth = true
            placeAddress.minimumScaleFactor = 0.5
            filledCircleLabel.text = "X"
            self.uberXLabel.text = "Uber X"
            self.confirmRideButton.setTitle("CONFIRM REQUEST", for: .normal)
            
        case.accepted:
            if userData?.accountType == .passenger {
                Service.shared.fetchUserData(userID: trip!.driverUID!) { (user) in
                    self.placeName.text = "Driver En Route"
                    self.placeAddress.text = ""
                    self.filledCircleLabel.text = String(user.fullname.first!)
                    self.uberXLabel.text = user.fullname
                    self.confirmRideButton.setTitle("CANCEL RIDE", for: .normal)
                }
            } else {
                Service.shared.fetchUserData(userID: trip!.passengerUID) { (user) in
                    self.placeName.text = "En Route To Passenger"
                    self.placeAddress.text = ""
                    self.filledCircleLabel.text = String(user.fullname.first!)
                    self.uberXLabel.text = user.fullname
                    self.confirmRideButton.setTitle("GET DIRECTIONS", for: .normal)
                }
            }
            
        case .driverArrived:
            if userData?.accountType == .passenger {
                self.placeName.text = "The Driver Has Arrived"
                self.placeAddress.text = "please meet your driver at pickup location"
            } else {
                self.placeName.text = "Arrived at passenger location"
                self.placeAddress.text = ""
                self.confirmRideButton.setTitle("PICKUP PASSENGER", for: .normal)
            }
            
        case .inProgress:
            if userData?.accountType == .passenger {
                guard let destinationAddress = trip?.destinationName else {return}
                self.placeName.text = "En Route To Destination"
                placeAddress.adjustsFontSizeToFitWidth = true
                placeAddress.minimumScaleFactor = 0.5
                self.placeAddress.text = "\(destinationAddress)"
            } else {
                guard let destinationAddress = acceptedTrip?.destinationName else {return}
                self.placeName.text = "En Route To Destination"
                placeAddress.adjustsFontSizeToFitWidth = true
                placeAddress.minimumScaleFactor = 0.5
                self.placeAddress.text = "\(destinationAddress)"
                self.confirmRideButton.setTitle("GET DIRECTIONS", for: .normal)
            }
            
        case .arrivedAtDestination:
            if userData?.accountType == .passenger {
                self.placeName.text = "Arrived At Destination"
                self.confirmRideButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                self.confirmRideButton.isEnabled = false

            } else {
                self.placeName.text = "Arrived At Destination"
                self.confirmRideButton.setTitle("DROP OFF PASSENGER", for: .normal)
            }
        case .completed:
            self.confirmRideButton.setTitle("CONFIRM REQUEST", for: .normal)
            self.confirmRideButton.isEnabled = true
        }
        
    }
    func setCircleRegion(identifier: String, coordinate: CLLocationCoordinate2D) {
        let circleRegion = CLCircularRegion(center: coordinate, radius: 20, identifier: identifier)
        locationManager.startMonitoring(for: circleRegion)
    }
    
    func currentTripState() {
        guard userData?.accountType == .passenger else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.isMyTripAccepted(uid: uid) { (trip) in
            switch trip.tripState {
            
            case.accepted:
                self.zoomInUserAndDriver = true
                Service.shared.driverLocationLive(uid: trip.driverUID!, mapView: self.mapView)
                let zoomInAnnotations = self.mapView.annotations.filter({ !$0.isKind(of: MKPointAnnotation.self) })
                self.mapView.fitAll(in: zoomInAnnotations, andShow: true)
                self.startActivityIndicator(false, message: nil)
                self.rideActionViewState = .accepted
                self.configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
                self.animateRideActionViewPassenger(const: 250, alpha: 0)
                self.cornerButton.alpha = 0
                
            case.rejected:
                self.showAlert(title: "Oops!", message: "a driver rejected your ride, Please search for another driver")
                self.startActivityIndicator(false, message: nil)
                self.mapView.removeAnnotationAndOverlays()
                self.animateRideActionViewPassenger(const: 0, alpha: 1)
                self.cornerButtonState = .sideMenu
                self.cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
                
            case.driverArrived:
                self.rideActionViewState = .driverArrived
                self.configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
            case.requested:
                break
            case.waitingToAccept:
                break
            case.inProgress:
                REF_DRIVER_LOCATION.child(trip.driverUID!).removeAllObservers()
                self.rideActionViewState = .inProgress
                self.configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
                self.mapView.annotations.forEach { (anno) in
                    if let annotation = anno as? DriverAnnotation {
                        self.mapView.removeAnnotation(annotation)
                    }
                }
                let zoomInAnnotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
                self.mapView.fitAll(in: zoomInAnnotations, andShow: true)
            case.arriverAtDestination:
                self.rideActionViewState = .arrivedAtDestination
                self.configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
            case.completed:
                self.rideActionViewState = .completed
                self.configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
                self.showAlert(title: "Trip Completed", message: "we hope you enjoyed your trip")
                self.mapView.removeAnnotationAndOverlays()
                self.animateRideActionViewPassenger(const: 0, alpha: 1)
            case .none:
                break

            }
        }
    }
    
    func cancleRideAndRemoveAllAnnos() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.cornerButtonState = .sideMenu
        cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
        Service.shared.cancleTheTrip(uid: uid)
        self.cornerButton.alpha = 1
        self.mapView.removeAnnotationAndOverlays()
        self.animateRideActionViewPassenger(const: 0, alpha: 1)
        self.confirmRideButton.setTitle("CONFIRM REQUEST", for: .normal)
    }

    
    func animateRideActionViewDriver(const: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.rideActionViewHeight.constant = const
            self.view.layoutIfNeeded()
        }
    }
    
    func animateRideActionViewPassenger(const: CGFloat, alpha: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.rideActionViewHeight.constant = const
            self.view.layoutIfNeeded()
            self.whereToView.alpha = alpha
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationInputController" {
            let destinationVC = segue.destination as! LocationInputController
            destinationVC.userFullName = self.userData?.fullname
            destinationVC.delegate = self
            
        } else if segue.identifier == "PickupController" {
            let destinationVC = segue.destination as! PickupController
            destinationVC.trip = self.trip
            destinationVC.delegate = self
        }
        
    }
    
    
    @IBAction func cornerButtonTapped(_ sender: UIButton) {
        switch cornerButtonState {
        case .sideMenu:
            signOut()
        case .back:
            self.cornerButtonState = .sideMenu
            cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
            self.mapView.removeAnnotationAndOverlays()
            self.animateRideActionViewPassenger(const: 0, alpha: 1)
        }
    }
    
    
    @IBAction func confirmRideButtonTapped(_ sender: UIButton) {
        
        switch rideActionViewState {
        case.requested:
            guard let pickupCoordinates = locationManager.location?.coordinate else {return}
            guard let destinationCoordinates = selectedPlace?.coordinate else {return}
            guard let thoroughFare = selectedPlace?.thoroughfare else {return}
            guard let subThoroughFare = selectedPlace?.subThoroughfare else {return}
            guard let destinationName = selectedPlace?.name else {return}
            let destinationAddress = "\(destinationName) \(thoroughFare) \(subThoroughFare)"
            Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates, destinationAddress)
            self.startActivityIndicator(true, message: "Finding you a ride...")
            self.animateRideActionViewPassenger(const: 0, alpha: 0)
            
        case.accepted:
            if userData?.accountType == .passenger {
                cancleRideAndRemoveAllAnnos()

            } else {
                print("getting directions")
            }
  
        case .driverArrived:
            if userData?.accountType == .passenger {
                cancleRideAndRemoveAllAnnos()
            } else {
                rideActionViewState = .inProgress
                guard let passengerUID = self.acceptedTrip?.passengerUID else {return}
                guard let destinationCoordinates = self.acceptedTrip?.destinationCoordinates else {return}
                let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates)
                setCircleRegion(identifier: CircularRegionType.destination.rawValue, coordinate: destinationCoordinates)
                configRideActionView(place: nil, trip: nil, config: rideActionViewState)
                Service.shared.updateTripState(uid: passengerUID, state: .inProgress)
                self.mapView.removeAnnotationAndOverlays()
                self.mapView.addAnnotation(coordinate: destinationCoordinates)
                self.zoomInUserAndPoint = true
                MapLocationServices.shared.showRoute(destination: destinationPlacemark) { (res, err) in
                    guard let polyline = res?.routes.first?.polyline else {return}
                    self.mapView.addOverlay(polyline)
                }
            }
        case .inProgress:
            if userData?.accountType == .passenger {
                cancleRideAndRemoveAllAnnos()
            } else {
                print("getting directions to destination from maps")
            }
        case .arrivedAtDestination:
            if userData?.accountType == .passenger {
                break
            } else {
                self.mapView.removeAnnotationAndOverlays()
                self.animateRideActionViewDriver(const: 0)
                Service.shared.updateTripState(uid: acceptedTrip!.passengerUID, state: TripState.completed)
                self.configureDriverUI()
            }
        case .completed:
            break
        }
 
    }
    

    @IBAction func searchTripsButtonTapped(_ sender: UIButton) {
        if self.searchTripsButton.tag == 0 {
            self.searchTripsButton.tag = 2
            UIView.animate(withDuration: 0.5) {
                self.searchTripsButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
            self.fetchTrips()
            
            
        } else if self.searchTripsButton.tag == 2 {
            self.searchTripsButton.tag = 0
            UIView.animate(withDuration: 0.5) {
                self.searchTripsButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            REF_TRIPS.removeAllObservers()
        }
        

    }
    
    
}







