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
import SideMenuSwift
import SVProgressHUD
import Combine



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
    @IBOutlet weak var searchTripsButton: LoadingButton!
    @IBOutlet weak var callButton: UIButton!
    
    
    var subscribtion = Set<AnyCancellable>()
    var viewModel = HomeViewModel()
    
    let hud = ProgressHUD.shared
    var rideActionViewState : RideActionViewConfiguration = .requested
    var cornerButtonState = CornerButtonConfiguration()
    var zoomInUser: Bool = false
    var zoomInUserAndPoint: Bool = false
    var zoomInUserAndDriver: Bool = false
    let locationManager = MapLocationServices.shared.locationManager
    var selectedPlace: MKPlacemark?
    var acceptedTrip: Trip?
    var driverPhoneNumber: String?

    var userData: User? {
        didSet {
            configurePassengerUI()
            configureDriverUI()
        }
    }
    
    var passengerTrip: Trip? {
        didSet {
            configureRideActionView()
        }
    }
    
    var driverTrip: Trip? {
        didSet {
            guard driverTrip != nil else {return}
            self.performSegue(withIdentifier: "PickupController", sender: self)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationStatus()
        configureStaticUI()
        configureSideMenu()
        addNotificationCenterObservers()
        setSubscribtion()
        	
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: - User Interface Methods
    
    func setSubscribtion() {
        subscribtion = [
            viewModel.$user.assign(to: \.userData, on: self),
            viewModel.$driverTrip.assign(to: \.driverTrip, on: self),
            viewModel.$passengerTrip.assign(to: \.passengerTrip, on: self)
        ]
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction.init(title: "OK".localize, style: .cancel, handler: nil)
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
    
    func configureStaticUI() {
        navigationController?.navigationBar.isHidden = true
        mapView.delegate = self
        rideActionViewHeight.constant = 0
        whereToView.alpha = 0
        searchTripsButton.alpha = 0
        callButton.layer.cornerRadius = callButton.frame.height/2
    }
    
    func configureDriverUI() {
        guard userData?.accountType == .driver else {return}

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
    
    func configureSideMenu() {
        SideMenuController.preferences.basic.menuWidth = self.view.frame.width/4 * 3
        SideMenuController.preferences.basic.position = .sideBySide
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
        SideMenuController.preferences.animation.shadowColor = UIColor.black
        SideMenuController.preferences.animation.shadowAlpha = 0.5
    }
    
    func configRideActionView(place: MKPlacemark?, trip: Trip?, config: RideActionViewConfiguration) {
        switch config {
        
        case.requested:
            let thoroughFare = place?.thoroughfare
            let subThoroughFare = place?.subThoroughfare
            let locality = place?.locality
            let adminArea = place?.administrativeArea
            placeName.text = place?.name
            placeAddress.text = "\(thoroughFare ?? "") \(subThoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
            placeAddress.adjustsFontSizeToFitWidth = true
            placeAddress.minimumScaleFactor = 0.5
            filledCircleLabel.text = "X"
            self.uberXLabel.text = "Uber X"
            self.confirmRideButton.setTitle("CONFIRM REQUEST".localize, for: .normal)
            self.callButton.alpha = 0
            
        case.accepted:
            if userData?.accountType == .passenger {
                viewModel.fetchUserData(uid: trip!.driverUID!) { (user) in
                    self.placeName.text = "Driver En Route".localize
                    self.placeAddress.text = ""
                    self.filledCircleLabel.text = String(user.firstname.first!)
                    self.uberXLabel.text = user.firstname + " " + user.surname
                    self.confirmRideButton.setTitle("CANCEL RIDE".localize, for: .normal)
                    self.callButton.alpha = 1
                }
            } else {
                viewModel.fetchUserData(uid: trip!.passengerUID!) { (user) in
                    self.placeName.text = "En Route To Passenger".localize
                    self.placeAddress.text = ""
                    self.filledCircleLabel.text = String(user.firstname.first!)
                    self.uberXLabel.text = user.firstname
                    self.confirmRideButton.setTitle("GET DIRECTIONS".localize, for: .normal)
                    self.callButton.alpha = 1
                }
            }
            
        case .driverArrived:
            if userData?.accountType == .passenger {
                self.placeName.text = "The Driver Has Arrived".localize
                self.placeAddress.text = "please meet your driver at pickup location".localize
            } else {
                self.placeName.text = "Arrived at passenger location".localize
                self.placeAddress.text = ""
                self.confirmRideButton.setTitle("PICKUP PASSENGER".localize, for: .normal)
            }
            
        case .inProgress:
            if userData?.accountType == .passenger {
                guard let destinationAddress = trip?.destinationName else {return}
                self.placeName.text = "En Route To Destination".localize
                placeAddress.adjustsFontSizeToFitWidth = true
                placeAddress.minimumScaleFactor = 0.5
                self.placeAddress.text = "\(destinationAddress)"
                self.callButton.alpha = 0
            } else {
                guard let destinationAddress = acceptedTrip?.destinationName else {return}
                self.placeName.text = "En Route To Destination".localize
                placeAddress.adjustsFontSizeToFitWidth = true
                placeAddress.minimumScaleFactor = 0.5
                self.placeAddress.text = "\(destinationAddress)"
                self.confirmRideButton.setTitle("GET DIRECTIONS".localize, for: .normal)
                self.callButton.alpha = 0
            }
            
        case .arrivedAtDestination:
            if userData?.accountType == .passenger {
                self.placeName.text = "Arrived At Destination".localize
                self.confirmRideButton.setTitle("ARRIVED AT DESTINATION".localize, for: .normal)
                self.confirmRideButton.isEnabled = false
                
            } else {
                self.placeName.text = "Arrived At Destination".localize
                self.confirmRideButton.setTitle("DROP OFF PASSENGER".localize, for: .normal)
            }
            
        case .completed:
            self.confirmRideButton.setTitle("CONFIRM REQUEST".localize, for: .normal)
            self.confirmRideButton.isEnabled = true
        }
    }
    
    func configureRideActionView() {
        guard passengerTrip != nil else {return}
        switch passengerTrip?.tripState {
        
        case.accepted:
            self.zoomInUserAndDriver = true
            viewModel.driverLocationLive(uid: passengerTrip!.driverUID!, mapView: self.mapView)
            let zoomInAnnotations = self.mapView.annotations.filter({ !$0.isKind(of: MKPointAnnotation.self) })
            self.mapView.fitAll(in: zoomInAnnotations, andShow: true)
            self.startActivityIndicator(false, message: nil)
            self.rideActionViewState = .accepted
            self.configRideActionView(place: nil, trip: passengerTrip, config: self.rideActionViewState)
            self.animateRideActionViewPassenger(const: 250, alpha: 0)
            self.cornerButton.alpha = 0
            self.driverPhoneNumber = passengerTrip?.driverPhoneNumber
            print("DEBUG: phone number driver \(self.driverPhoneNumber)")

        case.rejected:
            self.showAlert(title: "Oops!".localize, message: "a driver rejected your ride, Please search for another driver".localize)
            self.startActivityIndicator(false, message: nil)
            self.mapView.removeAnnotationAndOverlays()
            self.animateRideActionViewPassenger(const: 0, alpha: 1)
            self.cornerButtonState = .showSideMenu
            self.cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)

        case.driverArrived:
            self.rideActionViewState = .driverArrived
            self.configRideActionView(place: nil, trip: passengerTrip, config: self.rideActionViewState)

        case.requested:
            break

        case.waitingToAccept:
            break

        case.inProgress:
            viewModel.removeObservers(ref: REF_DRIVER_LOCATION, child: passengerTrip!.driverUID!)
            self.rideActionViewState = .inProgress
            self.configRideActionView(place: nil, trip: passengerTrip, config: self.rideActionViewState)
            self.mapView.annotations.forEach { (anno) in
                if let annotation = anno as? DriverAnnotation {
                    self.mapView.removeAnnotation(annotation)
                }
            }
            let zoomInAnnotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            self.mapView.fitAll(in: zoomInAnnotations, andShow: true)

        case.arriverAtDestination:
            self.rideActionViewState = .arrivedAtDestination
            self.configRideActionView(place: nil, trip: passengerTrip, config: self.rideActionViewState)

        case.completed:
            self.rideActionViewState = .completed
            self.configRideActionView(place: nil, trip: passengerTrip, config: self.rideActionViewState)
            self.showAlert(title: "Trip Completed".localize, message: "we hope you enjoyed your trip".localize)
            viewModel.saveCompletedTrip(trip: passengerTrip)
            self.mapView.removeAnnotationAndOverlays()
            self.animateRideActionViewPassenger(const: 0, alpha: 1)

        case .none:
            break
        }
    }
    
    
    func callPhoneNumber(number: String) {
        if let urlMobile = NSURL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(urlMobile as URL) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(urlMobile as URL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(urlMobile as URL)
            }
        }
    }
    
    
    func cancleRideAndRemoveAllAnnos() {
        self.cornerButtonState = .showSideMenu
        cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
        viewModel.cancelTrip()
        self.cornerButton.alpha = 1
        self.mapView.removeAnnotationAndOverlays()
        self.animateRideActionViewPassenger(const: 0, alpha: 1)
        self.confirmRideButton.setTitle("CONFIRM REQUEST".localize, for: .normal)
    }

    
    //MARK: - #Selectors and Side Menu Methods
    
    func addNotificationCenterObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertSignOut), name: NSNotification.Name(rawValue: "signout"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToSettingsController), name: NSNotification.Name(rawValue: "SettingsController"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToYourTripsController), name: NSNotification.Name(rawValue: "YourTripsController"), object: nil)
    }
    
    @objc func showAlertSignOut() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?".localize, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Logout".localize, style: .destructive) { _ in
            self.signOut()
        }
        let action2 = UIAlertAction(title: "Cancle".localize, style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func goToSettingsController() {
        self.sideMenuController?.hideMenu()
        performSegue(withIdentifier: "SettingsController", sender: self)
    }
    
    @objc func goToYourTripsController() {
        self.sideMenuController?.hideMenu()
        performSegue(withIdentifier: "YourTripsController", sender: self)
    }
    
    @objc func showLocationInputView() {
        self.sideMenuController?.hideMenu()
        performSegue(withIdentifier: "LocationInputController", sender: self)
    }
    
    
    func signOut() {
        Authentication.shared.signOut { (isSuccess, err) in
            if let err = err {
                print("\(err.localizedDescription)")
            }
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "signout"), object: nil)
            let vc: UIViewController = (storyboard?.instantiateViewController(identifier: "LoginController"))!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    //MARK: - Buttons Actions

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationInputController" {
            let destinationVC = segue.destination as! LocationInputController
            destinationVC.userFullName = "\(self.userData!.firstname) \(self.userData!.surname)"
            destinationVC.delegate = self
        } else if segue.identifier == "PickupController" {
            let destinationVC = segue.destination as! PickupController
            destinationVC.trip = self.driverTrip
            destinationVC.driverPhoneNumber = userData?.phonenumber
            destinationVC.delegate = self
        } else if segue.identifier == "YourTripsController" {
            let destinationVC = segue.destination as! YourTripsController
            destinationVC.user = self.userData
        }
    }
    
    
    @IBAction func cornerButtonTapped(_ sender: UIButton) {
        switch cornerButtonState {
        case .showSideMenu:
            self.sideMenuController?.revealMenu()
        case .dismissSideMenu:
            self.cornerButtonState = .showSideMenu
            cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
            self.mapView.removeAnnotationAndOverlays()
            self.animateRideActionViewPassenger(const: 0, alpha: 1)
        }
    }
    
    
    @IBAction func confirmRideButtonTapped(_ sender: UIButton) {
        
        switch rideActionViewState {
        case.requested:
            guard let selectedPlace = self.selectedPlace else {return}
            viewModel.uploadTrip(place: selectedPlace)
            self.startActivityIndicator(true, message: "Finding you a ride...".localize)
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
                viewModel.updateTripState(uid: passengerUID, state: .inProgress)
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
                viewModel.updateTripState(uid: acceptedTrip!.passengerUID, state: TripState.completed)
                self.configureDriverUI()
                viewModel.saveCompletedTrip(trip: acceptedTrip)
                
            }
            
        case .completed:
            break
        }
    }
    


    @IBAction func searchTripsButtonTapped(_ sender: LoadingButton) {
        
        if self.searchTripsButton.tag == 0 {
            self.searchTripsButton.tag = 2

            self.searchTripsButton.showLoading()
            viewModel.fetchTrips()
            print("DEBUG: FETCHING trips")

        } else if self.searchTripsButton.tag == 2 {
            self.searchTripsButton.tag = 0

            self.searchTripsButton.hideLoading()
            viewModel.removeObservers(ref: REF_TRIPS, child: nil)
            print("DEBUG: STOP FETCHING trips")
        }
    }

    
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        if userData?.accountType == .passenger {
            guard let driverNumber = self.driverPhoneNumber else {return}
            callPhoneNumber(number: driverNumber)
        } else {
            guard let passengerNumber = self.acceptedTrip?.passengerPhoneNumber else {return}
            callPhoneNumber(number: passengerNumber)
        }
    }
 
}








