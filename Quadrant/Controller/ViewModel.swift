//
//  ViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/7/21.
//

import Foundation
import Combine
import Firebase

class HomeViewModel {
    
    var uid = Auth.auth().currentUser?.uid ?? ""
    let locationManager = MapLocationServices.shared.locationManager
    
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
        fetchUserData()
    }
    
    func fetchUserData() {
        Service.shared.fetchUserData(userID: uid) { (user) in
            self.user = user
        }
    }
    
    func uploadPassengerLocation() {
        guard user?.accountType == .passenger else {return}
        guard let location = self.locationManager.location else {return}
        Service.shared.setPassengerLocation(location: location)
    }
    
    func uploadDriverLocation() {
        guard user?.accountType == .driver else {return}
        guard let location = self.locationManager.location else {return}
        Service.shared.setDriverLocation(location: location)
    }
    
    func fetchTrips() {
        guard user?.accountType == .driver else {return}
        Service.shared.fetchTrip(location: self.locationManager.location!) { (trip) in
            if trip.tripState == .requested {
                self.driverTrip = trip
            }
        }
    }
    
    func removeTripsObserver() {
        REF_TRIPS.removeAllObservers()
    }
    
    
    func cancelTrip() {
        Service.shared.cancleTheTrip(uid: uid)
    }
    
    
    func observeCurrentTrip() {
        guard user?.accountType == .passenger else {return}
        Service.shared.observeCurrentTrip(uid: uid) { (trip) in
            self.passengerTrip = trip
        }
    }
    
    
    
    
}
