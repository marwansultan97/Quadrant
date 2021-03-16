//
//  ViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/7/21.
//

import Foundation
import Combine
import Firebase
import CoreLocation
import MapKit

class HomeViewModel {
    
    var uid = Auth.auth().currentUser?.uid ?? ""
    let locationManager = MapLocationServices.shared.locationManager
    let services = Service.shared
    
    
    @Published var passengerTrip: Trip?
    @Published var driverTrip: Trip?
    @Published var user: User? {
        didSet {
            uploadPassengerLocation()
            uploadDriverLocation()
            observeCurrentTrip()
        }
    }
    
    init() {
        fetchMyData()
    }
    
    func fetchMyData() {
        services.fetchUserData(userID: uid) { (user) in
            self.user = user
            print(user.uid)
        }
    }
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        services.fetchUserData(userID: uid) { (user) in
            completion(user)
        }
    }
    
    
    func uploadPassengerLocation() {
        guard user?.accountType == .passenger else {return}
        guard let location = self.locationManager.location else {return}
        services.setPassengerLocation(location: location)
    }
    
    func uploadDriverLocation() {
        guard user?.accountType == .driver else {return}
        guard let location = self.locationManager.location else {return}
        services.setDriverLocation(location: location)
    }
    
    func fetchTrips() {
        guard user?.accountType == .driver else {return}
        services.fetchTrip(location: self.locationManager.location!) { (trip) in
            if trip.tripState == .requested {
                self.driverTrip = trip
            }
        }
    }

    func isTripCanceled(uid: String, completion: @escaping(DataSnapshot) -> Void) {
        services.isTheTripCancled(uid: uid, completion: completion)
    }
    
    func removeObservers(ref: DatabaseReference, child: String?) {
        if child != nil {
            ref.child(child!).removeAllObservers()
        } else {
            ref.removeAllObservers()
        }
    }
    
    
    func cancelTrip() {
        services.cancleTheTrip(uid: uid)
    }
    
    
    func observeCurrentTrip() {
        guard user?.accountType == .passenger else {return}
        services.observeCurrentTrip(uid: uid) { (trip) in
            self.passengerTrip = trip
        }
    }
    
    func uploadTrip(place: MKPlacemark) {
        guard let pickupCoordinates = locationManager.location?.coordinate else {return}
        let destinationCoordinates = place.coordinate
        let thoroughFare = place.thoroughfare
        let subThoroughFare = place.subThoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        let destinationName = place.name
        guard let passengerPhoneNumber = user?.phonenumber else {return}
        let destinationAddress = "\(destinationName ?? "") \(thoroughFare ?? "") \(subThoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
        services.uploadTrip(pickup: pickupCoordinates, destination: destinationCoordinates, destinationAddress: destinationAddress, passengerPhoneNumber: passengerPhoneNumber)
    }
    
    func updateTripState(uid: String, state: TripState) {
        services.updateTripState(uid: uid, state: state)
    }
    
    func saveCompletedTrip(trip: Trip?) {
        if user?.accountType == .passenger {
            guard let trip = trip else {return}
            guard let phonenumber = trip.driverPhoneNumber else {return}
            services.saveCompletedTrip(trip: trip, personType: "driverPhoneNumber", personPhoneNumber: phonenumber)
        } else {
            guard let trip = trip else {return}
            guard let phonenumber = trip.passengerPhoneNumber else {return}
            services.saveCompletedTrip(trip: trip, personType: "passengerPhoneNumber", personPhoneNumber: phonenumber)
        }
        
    }
    
    func driverLocationLive(uid: String, mapView: MKMapView) {
        services.driverLocationLive(uid: uid, mapView: mapView)
    }
    
    
    
    
    
}
