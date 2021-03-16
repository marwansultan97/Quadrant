//
//  Annotaions.swift
//  Uber
//
//  Created by Marwan Osama on 12/1/20.
//

import Foundation
import CoreLocation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    
    var uid: String
    dynamic var coordinate: CLLocationCoordinate2D
    var fullname: String
    
    
    init(fullname:String, uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
        self.fullname = fullname
    }
    
    func updateAnnotationPosition(newCoordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.5) {
            self.coordinate = newCoordinate
        }
    }
    
}
