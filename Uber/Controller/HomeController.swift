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

enum cornerButtonConfiguration {
    case sideMenu
    case normalState
}

class HomeController: UIViewController {
    
    
    @IBOutlet weak var cornerButton: UIButton!
    @IBOutlet weak var whereToView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    static let shared = HomeController()
    let locationManager = LocationHandler.shared.locationManager
    var userData: User?
    var cornerButtonState: cornerButtonConfiguration = .normalState
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationStatus()
        configureUI()
        configureMapView()
        fetchUserData()
        fetchDrivers()
        
    }
    
    func configureMapView() {
        self.mapView.delegate = self
        guard let location = locationManager?.location?.coordinate else {return}
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
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
        let alert = UIAlertController.init(title: "error", message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func configureUI() {
        whereToView.alpha = 0
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
    
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(userID: userID) { (user) in
            self.userData = user
        }
    }
    
    func fetchDrivers() {
        guard let location = locationManager?.location else {return}
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LocationInputController
        destinationVC.userFullName = self.userData?.fullname
        destinationVC.delegate = self
    }
    
    
    @IBAction func cornerButtonTapped(_ sender: UIButton) {
        switch cornerButtonState {
        case .normalState:
            break
        case .sideMenu:
            self.cornerButtonState = .normalState
            cornerButton.setImage(#imageLiteral(resourceName: "icons8-menu"), for: .normal)
            MapKit.shared.removeAnnotation(mapView: mapView)
            UIView.animate(withDuration: 1) {
                self.whereToView.alpha = 1
            }
        }
    }
    
}

//MARK: - LocationManager Methods
extension HomeController : CLLocationManagerDelegate {
    
    func authorizationStatus() {
        
        switch locationManager?.accuracyAuthorization {
        case .reducedAccuracy:
            locationManager?.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once")
        case .fullAccuracy:
            locationManager?.startUpdatingLocation()
        case .none:
            break
        @unknown default:
            break
        }
        
        switch locationManager?.authorizationStatus {
        case .denied, .restricted:
            break
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        case .none:
            break
        @unknown default:
            break
        }
    }
}

//MARK: - MapView Methods

extension HomeController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let annotationTitle = UILabel(frame: CGRect(x: 2, y: -15, width: 50, height: 30))
            annotationTitle.font = UIFont.systemFont(ofSize: 7)
            annotationTitle.text = annotation.fullname
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnnotation")
            annotationView.image = #imageLiteral(resourceName: "icons8-car_top_view")
            annotationView.addSubview(annotationTitle)
            return annotationView
        }

        return nil
    }
}

extension HomeController: ShowPlaceDetails {
    
    func showAnnotation(place: MKPlacemark) {
        self.cornerButtonState = .sideMenu
        self.cornerButton.setImage(#imageLiteral(resourceName: "icons8-back"), for: .normal)
        self.whereToView.alpha = 0
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        mapView.addAnnotation(annotation)
        UIView.animate(withDuration: 1) {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    
    
}



