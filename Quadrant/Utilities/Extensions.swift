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
            
            if let annotation = anno as? MKUserLocation {
                let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                setRegion(region, animated: true)
            }
        }
        if overlays.count > 0 {
            removeOverlay(overlays[0])
        }
    }
    
    func addAndSelectAnnotation(coordinate: CLLocationCoordinate2D) {
        let anno = MKPointAnnotation()
        anno.coordinate = coordinate
        addAnnotation(anno)
        selectAnnotation(anno, animated: true)
    }
    
//    func showRoute(destination: MKPlacemark, locationManager: CLLocationManager) {
//        let request = MKDirections.Request()
//        guard let currentCoordinations = locationManager.location?.coordinate else { return }
//        
//        let sourceCoordinations = CLLocationCoordinate2D(latitude: currentCoordinations.latitude, longitude: currentCoordinations.longitude)
//        
//        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinations)
//        
//        request.source = MKMapItem(placemark: sourcePlacemark)
//        request.destination = MKMapItem(placemark: destination)
//        request.transportType = .automobile
//        
//        let routeRequest = MKDirections(request: request)
//                
//        routeRequest.calculate { (response, err) in
//            guard let route = response?.routes.first else { return }
//        }
//    }

    
}

extension CLLocationCoordinate2D {
    
    func middleLocationWith(location1:CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {

        let lon1 = location1.longitude * Double.pi / 180
        let lon2 = location2.longitude * Double.pi / 180
        let lat1 = location1.latitude * Double.pi / 180
        let lat2 = location2.latitude * Double.pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)

        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)

        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / Double.pi, lon3 * 180 / Double.pi)
        
        return center
    }
}


extension String {
    
    var localize: String {
        return NSLocalizedString(self, comment: "")
    }
    
}



