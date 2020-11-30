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
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizationStatus()
        configureUI()
        Service.shared.fetchUserData()
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
        UIView.animate(withDuration: 2) {
            self.whereToView.alpha = 1
        }
        whereToView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLocationInputView)))
        
    }
    
    @objc func showLocationInputView() {
        performSegue(withIdentifier: "LocationInputController", sender: self)

    }
    
}

//MARK: - LocationManager Methods
extension HomeController : CLLocationManagerDelegate {
    
    func authorizationStatus() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch locationManager.accuracyAuthorization {
        case .reducedAccuracy:
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once")
        case .fullAccuracy:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
        
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .authorizedWhenInUse && locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once") { _ in
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        } else if locationManager.authorizationStatus == .authorizedAlways && locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once") { _ in
                self.locationManager.startUpdatingLocation()
            }
        } else if locationManager.accuracyAuthorization == .fullAccuracy {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locationManager.stopUpdatingLocation()
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            
        }
    }
}
