//
//  PickupViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/17/21.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase


class PickupDViewModel {
    
    
    var isTheTripCanceledBehavior = BehaviorRelay<Bool>(value: false)
    
    
    func isTheTripCancled(uid: String) {
        REF_TRIPS.child(uid).observeSingleEvent(of: .childRemoved) { [weak self] _ in
            self?.isTheTripCanceledBehavior.accept(true)
        }
    }
    
    
    func updateTripState(uid: String, state: TripState) {
        REF_TRIPS.child(uid).updateChildValues(["state": state.rawValue])
    }
    
    
    func acceptTheTrip(driverUser: User, trip: Trip) {
        let driverName = driverUser.firstname + " " + driverUser.surname
        let driverPhoneNumber = driverUser.phonenumber
        guard let passengerUID = trip.passengerUID else {return}
        
        let values: [String:Any] = [
            "driverName": driverName,
            "driverPhoneNumber": driverPhoneNumber,
            "driverUID": driverUser.uid,
            "state": TripState.accepted.rawValue
        ]
        
        REF_TRIPS.child(passengerUID).updateChildValues(values)
    }
    
    
    
    
}
