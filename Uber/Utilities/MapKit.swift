//
//  MapKit.swift
//  Uber
//
//  Created by Marwan Osama on 12/4/20.
//

import Foundation
import MapKit

class MapKit  {
    
    static let shared = MapKit()
    

    func removeAnnotation(mapView: MKMapView) {
        mapView.annotations.forEach { (anno) in
            if let annotation = anno as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    
    
    
    
    
}

