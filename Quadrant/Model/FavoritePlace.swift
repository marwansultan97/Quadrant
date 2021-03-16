//
//  FavoritePlace.swift
//  Uber
//
//  Created by Marwan Osama on 12/25/20.
//

import Foundation
import CoreLocation
import MapKit

struct FavoritePlace {
    
    var placeCoordinates: CLLocationCoordinate2D!
    var name: String!
    var thoroughFare: String!
    var subThoroughFare: String!
    var locality: String!
    var adminArea: String!
    
    init(values: [String:Any]) {
        
        if let coordinates = values["placeCoordinates"] as? NSArray {
            guard let lat = coordinates[0] as? CLLocationDegrees else {return}
            guard let long = coordinates[1] as? CLLocationDegrees else {return}
            self.placeCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.name = values["name"] as? String ?? ""
        self.thoroughFare = values["thoroughFare"] as? String ?? ""
        self.subThoroughFare = values["subThoroughFare"] as? String ?? ""
        self.locality = values["locality"] as? String ?? ""
        self.adminArea = values["adminArea"] as? String ?? ""

    }
    
}
