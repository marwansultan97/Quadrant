//
//  HomeDViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/16/21.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit
import Firebase
import GeoFire


class HomeDViewModel {
    
    
    let uid = Auth.auth().currentUser?.uid
    
    var isSignedOut = BehaviorRelay<Bool>(value: false)
    
    private var userSubject = PublishSubject<User>()
    var userObservable: Observable<User> {
        return userSubject.asObservable()
    }
    
    private var polylineSubject = PublishSubject<MKPolyline>()
    var polylineObservable: Observable<MKPolyline> {
        return polylineSubject.asObservable()
    }
    
    private var tripSubject = PublishSubject<Trip>()
    var tripObservable: Observable<Trip> {
        return tripSubject.asObservable()
    }
    
    var isTheTripCanceledBehavior = BehaviorRelay<Bool>(value: false)
    
    
    
    func fetchUser() {
        
        REF_USERS.child(uid!).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.userSubject.onNext(user)
        }
    }
    
    
    func showPolyline(destinationCoordinations: CLLocationCoordinate2D, locationManager: CLLocationManager) {
        let request = MKDirections.Request()
        guard let currentCoordinations = locationManager.location?.coordinate else {return}
        
        let sourceCoordinations = CLLocationCoordinate2D(latitude: currentCoordinations.latitude, longitude: currentCoordinations.longitude)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinations)
        
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinations)
        
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlaceMark)
        request.transportType = .automobile
        
        let routeRequest = MKDirections(request: request)
        
        routeRequest.calculate { [weak self] (response, err) in
            guard let polyline = response?.routes.first?.polyline else { return }
            self?.polylineSubject.onNext(polyline)
        }
    }
    
    
    func fetchTrip() {
        
        REF_TRIPS.queryOrdered(byChild: "state").queryEqual(toValue: TripState.requested.rawValue).observe(.childAdded, with: { [weak self] (snapshot) in
            guard let self = self else {return  }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            let distance = HomeDViewController.locationManager.location!.distance(from: CLLocation(latitude: trip.pickupCoordinates.latitude, longitude: trip.pickupCoordinates.longitude))
            if distance < 5000 {
                print("Distance Acceptable")
                self.tripSubject.onNext(trip)
                REF_TRIPS.removeAllObservers()
            } else {
                print("Very Far Distance")
            }
            
        })
    }
    
    func isTheTripCancled(uid: String) {
        REF_TRIPS.child(uid).observeSingleEvent(of: .childRemoved) { [weak self] _ in
            self?.isTheTripCanceledBehavior.accept(true)
        }
    }
    
    func updateTripState(uid: String, state: TripState) {
        REF_TRIPS.child(uid).updateChildValues(["state": state.rawValue])
    }
    
    func setDriverLocation(location: CLLocation) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        geofire.setLocation(location, forKey: uid!)
    }
    
    
    func saveCompletedTrip(trip: Trip) {
        
        let pickupCoordinates = [trip.pickupCoordinates.latitude, trip.pickupCoordinates.longitude]
        let destinationCoordinates = [trip.destinationCoordinates.latitude, trip.destinationCoordinates.longitude]
        let timeStamp = trip.date!
        let passengerName = trip.passengerName!
        let passengerPhoneNumber = trip.passengerPhoneNumber!
        let values: [String:Any] = ["pickupCoordinates": pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "destinationAddress": trip.destinationName!,
                                    "passengerName": passengerName,
                                    "passengerPhoneNumber": passengerPhoneNumber,
                                    "date": timeStamp]
        REF_COMPLETED_TRIPS.child(uid!).childByAutoId().updateChildValues(values)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isSignedOut.accept(true)
        } catch let err {
            print(err)
        }
    }
    
    
    
}
