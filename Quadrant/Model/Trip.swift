//
//  Trips.swift
//  Uber
//
//  Created by Marwan Osama on 12/9/20.
//

import Foundation
import CoreLocation

enum TripState: Int {
    case requested
    case waitingToAccept
    case accepted
    case rejected
    case driverArrived
    case inProgress
    case arriverAtDestination
    case completed
}


struct Trip {
    
    
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    var destinationName: String!
    let passengerUID: String!
    var passengerName: String!
    var passengerPhoneNumber: String!
    var driverPhoneNumber: String?
    var date: String!
    var driverName: String?
    var tripState: TripState!
    var driverUID: String?
    
    
    init(passengerUID: String, values: [String:Any]) {
        self.passengerUID = passengerUID
        
        if let pickup = values["pickupCoordinates"] as? NSArray {
            guard let lat = pickup[0] as? CLLocationDegrees else {return}
            guard let long = pickup[1] as? CLLocationDegrees else {return}
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destination = values["destinationCoordinates"] as? NSArray {
            guard let lat = destination[0] as? CLLocationDegrees else {return}
            guard let long = destination[1] as? CLLocationDegrees else {return}
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.destinationName = values["destinationAddress"] as? String
        
        self.driverName = values["driverName"] as? String ?? ""
        
        self.driverPhoneNumber = values["driverPhoneNumber"] as? String ?? ""
        
        self.passengerName = values["passengerName"] as? String ?? ""
        
        self.passengerPhoneNumber = values["passengerPhoneNumber"] as? String ?? ""
        
        self.driverUID = values["driverUID"] as? String ?? ""
        
        self.date = values["date"] as? String ?? ""
        
        if let state = values["state"] as? Int {
            self.tripState = TripState(rawValue: state)
        }
 
    }
    
    
}
