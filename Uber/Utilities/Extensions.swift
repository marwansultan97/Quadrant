//
//  Extensions.swift
//  Uber
//
//  Created by Marwan Osama on 12/10/20.
//

import Foundation
import MapKit
import Firebase


extension MKMapView {
    
    /// We call this function and give it the annotations we want added to the map. we display the annotations if necessary
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
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 20, bottom: 270, right: 20), animated: true)
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
        if overlays.count > 0 {
            removeOverlay(overlays[0])
        }
        
        let annotation = annotations.filter({ $0.isKind(of: MKUserLocation.self) })
        showAnnotations(annotation, animated: true)
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let anno = MKPointAnnotation()
        anno.coordinate = coordinate
        addAnnotation(anno)
        selectAnnotation(anno, animated: true)
    }
    
}



