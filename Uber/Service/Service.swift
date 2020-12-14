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
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")
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
    
    // Passenger Side
    func fetchDriver(location: CLLocation, completion: @escaping(User)-> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        
        REF_DRIVER_LOCATION.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(userID: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            }
            )}
    }
    
    // Passenger Side
    func uploadTrip( _ pickup: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D, _ completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let pickupCoordinates = [pickup.latitude, pickup.longitude]
        let destinationCoordinates = [destination.latitude, destination.longitude]
        let values: [String:Any] = ["pickupCoordinates":pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "state": TripState.requested.rawValue]
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    //Passenger Side
    func isMyTripAccepted(uid: String, completion: @escaping(Trip)-> Void) {
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            completion(trip)
        }
    }
    
//
//    func isMyTripCancled(uid: String) {
//        REF_TRIPS.child(uid).remo
//    }
    
    func cancleTheTrip(uid: String, completion: @escaping(Error?, DatabaseReference)-> Void) {
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func isTheTripCancled(uid: String, completion: @escaping(DataSnapshot)-> Void) {
        REF_TRIPS.child(uid).observe(.childRemoved, with: completion)
    }
    
    
    
    // Driver Side
    func fetchTrip(completion: @escaping(Trip)-> Void) {
        
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let trip = Trip(passengerUID: uid, values: dictionary)
            completion(trip)
        }
        
    }
    
    // Driver Side
    func acceptTheTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let driverUID = Auth.auth().currentUser?.uid else {return}
        guard let passengerUID = trip.passengerUID else {return}
        
        let values: [String:Any] = ["driverUID": driverUID, "state": TripState.accepted.rawValue]
        
        REF_TRIPS.child(passengerUID).updateChildValues(values, withCompletionBlock: completion)
    }

    
    
}
