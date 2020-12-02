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
    
    
    @IBOutlet weak var whereToView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = LocationHandler.shared.locationManager
    var userData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationStatus()
        configureUI()
        configureMapView()
        fetchUserData()
        fetchDrivers()
        
        
    }
    
    func configureMapView() {
        mapView.delegate = self
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
        whereToView.layer.shadowOpacity = 0.5
        whereToView.layer.shadowOffset = CGSize(width: 3, height: 3)
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
            print("DEBUG: your driver is \(driver)")
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
