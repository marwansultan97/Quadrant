//
//  HomePViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/15/21.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit
import Firebase

class HomePViewModel {
    
    let uid = Auth.auth().currentUser?.uid
    var date = Date()
    
    private var userSubject = PublishSubject<User>()
    var userObservable: Observable<User> {
        return userSubject.asObservable()
    }
    
    private var routeSubject = PublishSubject<MKRoute>()
    var routeObservable: Observable<MKRoute> {
        return routeSubject.asObservable()
    }
    
    private var polylineSubject = PublishSubject<MKPolyline>()
    var polylineObservable: Observable<MKPolyline> {
        return polylineSubject.asObservable()
    }

    
    private var currentTripSubject = PublishSubject<Trip>()
    var currentTripObservable: Observable<Trip> {
        return currentTripSubject.asObservable()
    }
    
    
    
    func fetchUser() {
        REF_USERS.child(uid!).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.userSubject.onNext(user)
        }
    }
    
    func showRoute(destination: MKPlacemark, locationManager: CLLocationManager) {
        let request = MKDirections.Request()
        guard let currentCoordinations = locationManager.location?.coordinate else {return}
        
        let sourceCoordinations = CLLocationCoordinate2D(latitude: currentCoordinations.latitude, longitude: currentCoordinations.longitude)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinations)
        
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        
        let routeRequest = MKDirections(request: request)
        
        routeRequest.calculate { [weak self] (response, err) in
            guard let route = response?.routes.first else { return }
            self?.routeSubject.onNext(route)
        }
    }
    
    func showPolyline(destination: MKPlacemark, locationManager: CLLocationManager) {
        let request = MKDirections.Request()
        guard let currentCoordinations = locationManager.location?.coordinate else {return}
        
        let sourceCoordinations = CLLocationCoordinate2D(latitude: currentCoordinations.latitude, longitude: currentCoordinations.longitude)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinations)
        
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        
        let routeRequest = MKDirections(request: request)
        
        routeRequest.calculate { [weak self] (response, err) in
            guard let polyline = response?.routes.first?.polyline else { return }
            self?.polylineSubject.onNext(polyline)
        }
    }
    
    
    
    
    func uploadTrip(pickup: CLLocationCoordinate2D, destinationPlace: MKPlacemark, user: User) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let dateformmater = DateFormatter()
        dateformmater.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        let timeStamp = dateformmater.string(from: self.date)
        
        let passengerName = user.firstname + " " + user.surname
        let passengerPhoneNumber = user.phonenumber
        
        let destinationCoordinations = destinationPlace.coordinate
        let thoroughFare = destinationPlace.thoroughfare
        let subThoroughFare = destinationPlace.subThoroughfare
        let locality = destinationPlace.locality
        let adminArea = destinationPlace.administrativeArea
        let destinationName = destinationPlace.name
        
        let destinationAddress = "\(destinationName ?? "") \(thoroughFare ?? "") \(subThoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
        

        let pickupCoordinates = [pickup.latitude, pickup.longitude]
        let destinationCoordinates = [destinationCoordinations.latitude, destinationCoordinations.longitude]
        let values: [String:Any] = ["pickupCoordinates":pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "destinationAddress": destinationAddress,
                                    "passengerName": passengerName,
                                    "passengerPhoneNumber": passengerPhoneNumber,
                                    "state": TripState.requested.rawValue,
                                    "date": timeStamp]
        REF_TRIPS.child(uid).updateChildValues(values)
        
    }
    
    func driverLocationLive(uid: String, mapView: MKMapView, completion: @escaping() -> Void) {
        REF_DRIVER_LOCATION.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let location = dictionary["l"] as? NSArray else {return}
            guard let lat = location[0] as? CLLocationDegrees else {return}
            guard let long = location[1] as? CLLocationDegrees else {return}
            let driverCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = DriverAnnotation(fullname: "", uid: uid, coordinate: driverCoordinate)
            var isDriverPlaceChanged: Bool {
                return mapView.annotations.contains { (anno) -> Bool in
                    guard let driverAnnotation = anno as? DriverAnnotation else {return false}
                    if driverAnnotation.uid == annotation.uid {
                        driverAnnotation.updateAnnotationPosition(newCoordinate: driverCoordinate)
                        return true
                    }
                    return false
                }
            }
            if !isDriverPlaceChanged {
                mapView.addAnnotation(annotation)
                completion()
            }
        }
    }
    
    
    func observeCurrentTripState() {
        
        REF_TRIPS.child(uid!).observe(.value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            self.currentTripSubject.onNext(trip)
        }
    }
    
    func removeObserverAndValueTrip() {
        REF_TRIPS.child(uid!).removeAllObservers()
        REF_TRIPS.child(uid!).removeValue()
    }
    
    func saveCompletedTrip(trip: Trip) {
        
        let pickupCoordinates = [trip.pickupCoordinates.latitude, trip.pickupCoordinates.longitude]
        let destinationCoordinates = [trip.destinationCoordinates.latitude, trip.destinationCoordinates.longitude]
        let timeStamp = trip.date!
        let passengerName = trip.driverName!
        let passengerPhoneNumber = trip.driverPhoneNumber!
        let values: [String:Any] = ["pickupCoordinates": pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "destinationAddress": trip.destinationName!,
                                    "driverName": passengerName,
                                    "driverPhoneNumber": passengerPhoneNumber,
                                    "date": timeStamp]
        REF_COMPLETED_TRIPS.child(uid!).childByAutoId().updateChildValues(values)
    }
    
}
