//
//  Service.swift
//  Uber
//
//  Created by Marwan Osama on 11/30/20.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation
import MapKit
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")
let REF_USER_LOCATION = DB_REF.child("user-location")
let REF_TRIPS = DB_REF.child("trips")
let REF_CANCLED = DB_REF.child("cancled_trips")

class Service {
    
    static let shared = Service()
    

    func fetchUserData(userID: String, completion: @escaping (User)-> Void) {
        REF_USERS.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
        
    }
    
    func updateTripState(uid: String, state: TripState) {
        REF_TRIPS.child(uid).updateChildValues(["state": state.rawValue])
    }
    
    //MARK: - Passenger Side Backend Methods
    
    
    func setPassengerLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: REF_USER_LOCATION)
        geofire.setLocation(location, forKey: uid)
    }
    
    
//    func fetchDriver(location: CLLocation, mapView: MKMapView, completion: @escaping(User)-> Void) {
//        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
//
//        REF_DRIVER_LOCATION.observe(.value) { (snapshot) in
//            geofire.query(at: location, withRadius: 5).observe(.keyEntered, with: { (uid, location) in
//                self.fetchUserData(userID: uid) { (user) in
//                    var driver = user
//                    driver.location = location
//                    guard let driverCoordinates = driver.location?.coordinate else {return}
//                    let annotaions = DriverAnnotation(fullname: driver.fullname, uid: driver.uid, coordinate: driverCoordinates)
//                    var isDriverAdded: Bool {
//                        return mapView.annotations.contains { (annotation) -> Bool in
//                            guard let driverAnno = annotation as? DriverAnnotation else { return false }
//                            if driverAnno.uid == annotaions.uid {
//                                driverAnno.updateAnnotationPosition(newCoordinate: driverCoordinates)
//                                return true
//                            }
//                            return false
//                        }
//                    }
//                    if !isDriverAdded {
//                        mapView.addAnnotation(annotaions)
//                    }
//                    completion(driver)
//                }
//            }
//            )}
//
//        REF_DRIVER_LOCATION.observe(.childRemoved) { (snapshot) in
//            let driverUID = snapshot.key
//            mapView.annotations.contains { (anno) in
//                guard let annos = anno as? DriverAnnotation else {return false}
//                if annos.uid == driverUID {
//                    mapView.removeAnnotation(anno)
//                    return true
//                }
//                return false
//            }
//
//        }
//    }
    
    func driverLocationLive(uid: String, mapView: MKMapView) {
        REF_DRIVER_LOCATION.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let location = dictionary["l"] as? NSArray else {return}
            guard let lat = location[0] as? CLLocationDegrees else {return}
            guard let long = location[1] as? CLLocationDegrees else {return}
            var driverCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = DriverAnnotation(fullname: "", uid: uid, coordinate: driverCoordinate)
            var isDriverPlaceChanged: Bool {
                return mapView.annotations.contains { (anno) -> Bool in
                    guard let annos = anno as? DriverAnnotation else {return false}
                    if annos.uid == annotation.uid {
                        annos.updateAnnotationPosition(newCoordinate: driverCoordinate)
                        return true
                    }
                    return false
                }
            }
            if !isDriverPlaceChanged {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    func uploadTrip( _ pickup: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D, _ destinationAddress: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let pickupCoordinates = [pickup.latitude, pickup.longitude]
        let destinationCoordinates = [destination.latitude, destination.longitude]
        let values: [String:Any] = ["pickupCoordinates":pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "destinationAddress": destinationAddress,
                                    "state": TripState.requested.rawValue]
        REF_TRIPS.child(uid).updateChildValues(values)
        
    }
    
    func isMyTripAccepted(uid: String, completion: @escaping(Trip)-> Void) {

        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            completion(trip)
        }
    }

    
    func cancleTheTrip(uid: String) {
        REF_TRIPS.child(uid).removeValue()
    }
    
    
    
    
    //MARK: - Driver Side Backend Methods
    
    func fetchTrip(location: CLLocation, completion: @escaping(Trip)-> Void) {
        
        REF_TRIPS.queryOrdered(byChild: "state").queryEqual(toValue: TripState.requested.rawValue).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            completion(trip)
            REF_TRIPS.removeAllObservers()
        })
    }
    
    
    
    func isTheTripCancled(uid: String, completion: @escaping(DataSnapshot)-> Void) {
        REF_TRIPS.child(uid).observeSingleEvent(of: .childRemoved, with: completion)
    }
    
    
    func acceptTheTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let driverUID = Auth.auth().currentUser?.uid else {return}
        guard let passengerUID = trip.passengerUID else {return}
        let values: [String:Any] = ["driverUID": driverUID, "state": TripState.accepted.rawValue]
        
        REF_TRIPS.child(passengerUID).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func setDriverLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        geofire.setLocation(location, forKey: uid)
    }
    

    
    
}
