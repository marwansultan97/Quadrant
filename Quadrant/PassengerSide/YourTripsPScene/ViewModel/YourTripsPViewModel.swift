//
//  YourTripsPViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/19/21.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import GeoFire

class YourTripsPViewModel {
    
    let uid = Auth.auth().currentUser?.uid
    
    
    var tripsBehavior = BehaviorRelay<[Trip]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    var noTripsError = BehaviorRelay<String>(value: "")
    
    
    func fetchCompletedTrips() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        isLoading.accept(true)
        var trips = [Trip]()
        REF_COMPLETED_TRIPS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            snapshot.children.forEach { (child) in
                if let child = child as? DataSnapshot {
                    guard let dictionary = child.value as? [String:Any] else {return}
                    let trip = Trip(passengerUID: child.key, values: dictionary)
                    trips.append(trip)
                }
            }
            self.isLoading.accept(false)
            
            if trips.isEmpty {
                self.noTripsError.accept("There aren't any Trips...")
            } else {
                self.tripsBehavior.accept(trips)
            }
            
        }
    }
    
    
    
}
