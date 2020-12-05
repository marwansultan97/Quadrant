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
    
    
    let locationManager = LocationHandler.shared.locationManager
    var userData: User?
    var cornerButtonState: cornerButtonConfiguration = .normalState
    var route: MKRoute?
    

    
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
        DispatchQueue.main.async {
            guard let location = self.locationManager?.location?.coordinate else {return}
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.showsUserLocation = true
            self.mapView.userTrackingMode = .follow
        }
        
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







