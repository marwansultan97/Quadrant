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
    
    
    var rideActionViewState = RideActionViewConfiguration()
    var cornerButtonState = CornerButtonConfiguration()
    var mapFinishedLoading: Bool = false
    var zoomIn: Bool = false
    var route: MKRoute?
    let locationManager = MapLocationServices.shared.locationManager
    var selectedPlace: MKPlacemark?

    var userData: User? {
        didSet {
            configureUI()
            fetchDrivers(location: locationManager.location!)
            fetchTrips()
            isMyTripAccepted()
            isMyTripCancled()
        }
    }
    
    var trip: Trip?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        authorizationStatus()
        fetchUserData()
        whereToView.alpha = 0
        
    }
    
    
    func signOut() {
        Authentication.shared.signOut { (isSuccess, err) in
            if let err = err {
                showAlert(message: err.localizedDescription)
            }
            // go to Login screen
            let vc: UIViewController = (storyboard?.instantiateViewController(identifier: "LoginController"))!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController.init(title: "Alert", message: message, preferredStyle: .actionSheet)
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
    
    func configureUI() {
        guard userData?.accountType == .passenger else {return}
        whereToView.layer.shadowColor = UIColor.label.cgColor
        whereToView.layer.shadowOpacity = 1
        whereToView.layer.shadowOffset = CGSize(width: 0, height: 0)
        whereToView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLocationInputView)))
        UIView.animate(withDuration: 2) {
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
     // get Drivers available around the passenger
    func fetchDrivers(location: CLLocation) {
        guard userData?.accountType == .passenger else {return}
        Service.shared.fetchDriver(location: location) { (driver) in

            guard let driverCoordinates = driver.location?.coordinate else {return}
            let annotaions = DriverAnnotation(fullname: driver.fullname, uid: driver.uid, coordinate: driverCoordinates)
            var isDriverAdded: Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    if driverAnno.uid == annotaions.uid {
                        driverAnno.updateAnnotationPosition(newCoordinate: driverCoordinates)
                        return true
                    }
                    return false
                }
            }
            if !isDriverAdded {
                self.mapView.addAnnotation(annotaions)
            }
        }
    }
    
    func fetchTrips() {
        guard userData?.accountType == .driver else {return}
        Service.shared.fetchTrip { (trip) in
            self.trip = trip
            self.performSegue(withIdentifier: "PickupController", sender: self)
        }

        
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
            confirmRideButton.setTitle("CONFIRM REQUEST", for: .normal)
            
        case.acceptedDriverSide:
            Service.shared.fetchUserData(userID: trip!.passengerUID) { (user) in
                self.placeName.text = "En Route To Passenger"
                self.placeAddress.text = ""
                self.filledCircleLabel.text = String(user.fullname.first!)
                self.uberXLabel.text = user.fullname
                self.confirmRideButton.setTitle("GET DIRECTIONS", for: .normal)
            }
            
        case.acceptedPassengerSide:
            Service.shared.fetchUserData(userID: trip!.driverUID!) { (user) in
                self.placeName.text = "Driver En Route"
                self.placeAddress.text = ""
                self.filledCircleLabel.text = String(user.fullname.first!)
                self.uberXLabel.text = user.fullname
                self.confirmRideButton.setTitle("CANCLE RIDE", for: .normal)
            }
        }
    }
    
    func isMyTripAccepted() {
        guard userData?.accountType == .passenger else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.isMyTripAccepted(uid: uid) { (trip) in
            if trip.tripState == .accepted {
                self.startActivityIndicator(false, message: nil)
                self.rideActionViewState = .acceptedPassengerSide
                self.configRideActionView(place: nil, trip: trip, config: self.rideActionViewState)
                self.animateRideActionViewPassenger(const: 250, alpha: 0)
                
            }
        }
    }
    
    func isMyTripCancled() {
        guard userData?.accountType == .passenger else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.isTheTripCancled(uid: uid) { (snapshot) in
            self.showAlert(message: "a driver rejected your ride, we are searching you another one")
            self.startActivityIndicator(false, message: nil)
            MapLocationServices.shared.removeAnnotation(mapView: self.mapView)
            self.animateRideActionViewPassenger(const: 0, alpha: 1)
            
        }
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
            MapLocationServices.shared.removeAnnotation(mapView: mapView)
            UIView.animate(withDuration: 0.5) {
                self.whereToView.alpha = 1
                self.rideActionViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    @IBAction func confirmRideButtonTapped(_ sender: UIButton) {
        switch rideActionViewState {
        case.requested:
            guard let pickupCoordinates = locationManager.location?.coordinate else {return}
            guard let destinationCoordinates = selectedPlace?.coordinate else {return}
            Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (err, ref) in
                if err != nil {
                    print("Failed to upload trip \(err!.localizedDescription)")
                    return
                }
                print("DEBUG: trip upload success")
                self.startActivityIndicator(true, message: "Finding you a ride...")
                UIView.animate(withDuration: 0.3) {
                    self.rideActionViewHeight.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        case.acceptedDriverSide:
            print("getting directions")
        case.acceptedPassengerSide:
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Service.shared.cancleTheTrip(uid: uid) { (err, ref) in
                MapLocationServices.shared.removeAnnotation(mapView: self.mapView)
                self.animateRideActionViewPassenger(const: 0, alpha: 1)
                
            }
        }
        
        
    }
    
}







