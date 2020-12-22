//
//  PickupController.swift
//  Uber
//
//  Created by Marwan Osama on 12/10/20.
//

import UIKit
import MapKit
import Firebase

protocol PickupControllerDelegate: class {
    func showRoute(trip: Trip)
    func dismiss()
    func searchForAnotherTrip()
}

class PickupController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var acceptTripButton: UIButton!
    
    var trip: Trip? {
        didSet {
            // if the Passeneger Cancled the search dismiss the Pickup Controller
            guard let uid = trip?.passengerUID else {return}
            
            Service.shared.isTheTripCancled(uid: uid) { (snapshot) in
                self.navigationController?.popViewController(animated: true)
                self.delegate?.dismiss()
            }
        }
    }
    var delegate: PickupControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        mapView.delegate = self
        guard let uid = trip?.passengerUID else {return}
        REF_TRIPS.child(uid).updateChildValues(["state": TripState.waitingToAccept.rawValue])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureMapView()
    }
    
    func configureUI() {
        acceptTripButton.layer.cornerRadius = acceptTripButton.frame.height/2
    }
    
    func configureMapView() {
        mapView.layer.cornerRadius = mapView.frame.height/2
        self.mapView.addAnnotation(coordinate: self.trip!.pickupCoordinates)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: self.trip!.pickupCoordinates, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    // the Driver will Reject the trip and delete it from Firebase
    func showWarningAlert() {
        let alert = UIAlertController(title: "Warning", message: "Do you really want to cancle the trip?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let uid = self.trip?.passengerUID else {return}
            Service.shared.updateTripState(uid: uid, state: .rejected)
            self.navigationController?.popViewController(animated: true)
            self.delegate?.searchForAnotherTrip()
            
        }
        
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showConfirmationAlert() {
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to Accept the trip?", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Yes", style: .default) { _ in
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Service.shared.acceptTheTrip(trip: self.trip!) { (err, ref) in
                self.trip?.driverUID = uid
                self.trip?.tripState = .accepted
                self.delegate?.showRoute(trip: self.trip!)
            }
            self.navigationController?.popViewController(animated: true)
        }
        
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    


    @IBAction func cancleButtonTapped(_ sender: UIButton) {
        showWarningAlert()
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        showConfirmationAlert()
    }
    
    
}


extension PickupController: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        let annotations = mapView.annotations.filter({ $0.isKind(of: MKPointAnnotation.self) })
        mapView.showAnnotations(annotations, animated: true)
    }
    
}
