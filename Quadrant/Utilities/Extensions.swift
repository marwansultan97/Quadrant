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
        if overlays.count > 0 {
            removeOverlay(overlays[0])
        }
    }
    
    func centerMapOnUser() {
        annotations.forEach { (anno) in
            if let annotation = anno as? MKUserLocation {
                let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
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


extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}



extension String {
    
    var localize: String {
        return NSLocalizedString(self, comment: "")
    }
    
}



