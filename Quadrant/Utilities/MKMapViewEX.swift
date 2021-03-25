//
//  MKMapViewEX.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/23/21.
//

import Foundation
import MapKit
import Firebase


extension MKMapView {
    
    // We call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
        
        for annotation in annotations {
            let point = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
            
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 50, bottom: 400, right: 50), animated: true)
    }
    
    
    
    func removeAnnotationAndOverlays() {
        annotations.forEach { (anno) in
            if let annotation = anno as? MKPointAnnotation {
                removeAnnotation(annotation)
            }
            if let annotation = anno as? DriverAnnotation {
                removeAnnotation(annotation)
            }
        }
        overlays.forEach { (overlay) in
            removeOverlay(overlay)
        }
    }
    
    func centerMapOnUser() {
        annotations.forEach { (anno) in
            if let annotation = anno as? MKUserLocation {
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                setRegion(region, animated: true)
            }
        }
    }
    
    func addAndSelectAnnotation(coordinate: CLLocationCoordinate2D) {
        let anno = MKPointAnnotation()
        anno.coordinate = coordinate
        addAnnotation(anno)
        selectAnnotation(anno, animated: true)
    }
    
    
    
}
