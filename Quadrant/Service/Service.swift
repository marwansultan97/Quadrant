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
let REF_FAVORITE_PLACES = DB_REF.child("favorite-places")
let REF_COMPLETED_TRIPS = DB_REF.child("completed_trips")
let REF_TEXT = DB_REF.child("text")

class Service {
    
    static let shared = Service()
    let date = Date()
    
    // done
    func fetchUserData(userID: String, completion: @escaping (User)-> Void) {
        REF_USERS.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
        
    }
    
    
    
    func saveCompletedTrip(trip: Trip, personType: String, personPhoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let dateformmater = DateFormatter()
        dateformmater.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        let timeStamp = dateformmater.string(from: self.date)
        
        let pickupCoordinates = [trip.pickupCoordinates.latitude, trip.pickupCoordinates.longitude]
        let destinationCoordinates = [trip.destinationCoordinates.latitude, trip.destinationCoordinates.longitude]
        let values: [String:Any] = ["pickupCoordinates": pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "destinationAddress": trip.destinationName!,
                                    personType: personPhoneNumber,
                                    "date": timeStamp]
        REF_COMPLETED_TRIPS.child(uid).childByAutoId().updateChildValues(values)
    }
    
    func fetchCompletedTrips(completion: @escaping([Trip])-> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        var trips = [Trip]()
        REF_COMPLETED_TRIPS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach { (child) in
                if let child = child as? DataSnapshot {
                    guard let dictionary = child.value as? [String:Any] else {return}
                    let trip = Trip(passengerUID: child.key, values: dictionary)
                    trips.append(trip)
                }
            }
            completion(trips)
        }
    }
    
    
    
    //MARK: - Passenger Side Backend Methods
    
    
    func setPassengerLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: REF_USER_LOCATION)
        geofire.setLocation(location, forKey: uid)
    }

    // done
    func driverLocationLive(uid: String, mapView: MKMapView) {
        REF_DRIVER_LOCATION.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let location = dictionary["l"] as? NSArray else {return}
            guard let lat = location[0] as? CLLocationDegrees else {return}
            guard let long = location[1] as? CLLocationDegrees else {return}
            let driverCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
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
    
    // done
    func uploadTrip(pickup: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, destinationAddress: String,  passengerPhoneNumber: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let dateformmater = DateFormatter()
        dateformmater.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        let timeStamp = dateformmater.string(from: self.date)
        
        let pickupCoordinates = [pickup.latitude, pickup.longitude]
        let destinationCoordinates = [destination.latitude, destination.longitude]
        let values: [String:Any] = ["pickupCoordinates":pickupCoordinates,
                                    "destinationCoordinates": destinationCoordinates,
                                    "destinationAddress": destinationAddress,
                                    "passengerPhoneNumber": passengerPhoneNumber,
                                    "state": TripState.requested.rawValue,
                                    "date": timeStamp]
        REF_TRIPS.child(uid).updateChildValues(values)
        
    }
    
    // done
    func observeCurrentTrip(uid: String, completion: @escaping(Trip)-> Void) {
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            completion(trip)
        }
    }
    
    // done
    func cancleTheTrip(uid: String) {
        REF_TRIPS.child(uid).removeValue()
    }
    
    // done
    func updateFavoritePlaces(uid: String, placeType: String, place: MKPlacemark, completion: @escaping(Error?, DatabaseReference)-> Void) {
        let name = place.name
        let thoroughFare = place.thoroughfare
//        let subThoroughFare = place.subThoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        
        let placeCoordinates = [place.coordinate.latitude, place.coordinate.longitude]
        
        let values: [String:Any] = ["placeCoordinates": placeCoordinates,
                                    "name": name ?? "",
                                    "thoroughFare": thoroughFare ?? "",
                                    "locality": locality ?? "",
                                    "adminArea": adminArea ?? ""]
        REF_FAVORITE_PLACES.child(uid).child(placeType).updateChildValues(values, withCompletionBlock: completion)
    }
    
    // done
    func fetchFavouritePlaces(uid: String, childName: String, completion: @escaping(FavoritePlace)-> Void) {
        REF_FAVORITE_PLACES.child(uid).child(childName).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let homePlace = FavoritePlace(values: dictionary)
            completion(homePlace)
        }
    }
    
    // done
    func convertFavoritePlaceToPlaceMark(place: FavoritePlace) -> MKPlacemark  {
        let addressDictionary: [String:Any] = ["Name": place.name ?? "",
                                               "Thoroughfare": place.thoroughFare ?? "",
                                               "City": place.locality ?? "",
                                               "State": place.adminArea ?? ""]
        let placeMark = MKPlacemark(coordinate: place.placeCoordinates, addressDictionary: addressDictionary)
        return placeMark
    }
    

    
    
    
    
    //MARK: - Driver Side Backend Methods
    
    // done
    func fetchTrip(location: CLLocation, completion: @escaping(Trip)-> Void) {
        
        REF_TRIPS.queryOrdered(byChild: "state").queryEqual(toValue: TripState.requested.rawValue).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let passengerUID = snapshot.key
            let trip = Trip(passengerUID: passengerUID, values: dictionary)
            completion(trip)
            REF_TRIPS.removeAllObservers()
        })
    }
    
    // done
    func isTheTripCancled(uid: String, completion: @escaping(DataSnapshot)-> Void) {
        REF_TRIPS.child(uid).observeSingleEvent(of: .childRemoved, with: completion)
    }
    
    // done
    func acceptTheTrip(driverPhoneNumber: String, trip: Trip, completion: @escaping(Error?, DatabaseReference)-> Void) {
        guard let driverUID = Auth.auth().currentUser?.uid else {return}
        guard let passengerUID = trip.passengerUID else {return}
        let values: [String:Any] = ["driverUID": driverUID, "state": TripState.accepted.rawValue, "driverPhoneNumber": driverPhoneNumber]
        
        REF_TRIPS.child(passengerUID).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func setDriverLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        geofire.setLocation(location, forKey: uid)
    }
    
    // done
    func updateTripState(uid: String, state: TripState) {
        REF_TRIPS.child(uid).updateChildValues(["state": state.rawValue])
    }
    
    
}
