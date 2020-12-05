//
//  Extenstions.swift
//  Uber
//
//  Created by Marwan Osama on 12/5/20.
//

import Foundation
import Firebase
import MapKit
import CoreLocation


//MARK: - Check Location Authorization Status
extension HomeController : CLLocationManagerDelegate {
    
    func authorizationStatus() {
        
        switch locationManager?.accuracyAuthorization {
        case .reducedAccuracy:
            locationManager?.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once")
        case .fullAccuracy:
            locationManager?.startUpdatingLocation()
        case .none:
            break
        @unknown default:
            break
        }
        
        switch locationManager?.authorizationStatus {
        case .denied, .restricted:
            break
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        case .none:
            break
        @unknown default:
            break
        }
    }
}

//MARK: - Create Custom Annotation for The Drivers
extension HomeController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let annotationTitle = UILabel(frame: CGRect(x: 2, y: -15, width: 50, height: 30))
            annotationTitle.font = UIFont.systemFont(ofSize: 7)
            annotationTitle.text = annotation.fullname
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "DriverAnnotation")
            annotationView.image = #imageLiteral(resourceName: "icons8-car_top_view")
            annotationView.addSubview(annotationTitle)
            return annotationView
        }

        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = .black
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKPolylineRenderer()

    }
    
}


//MARK: - Show Annotation and Route for the place
extension HomeController: ShowPlaceDetails {
    
    func showAnnotation(place: MKPlacemark) {
        self.cornerButtonState = .sideMenu
        self.cornerButton.setImage(#imageLiteral(resourceName: "icons8-back"), for: .normal)
        self.whereToView.alpha = 0
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        mapView.addAnnotation(annotation)
        self.showPlaceRoute(place: place)

        UIView.animate(withDuration: 1) {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func showPlaceRoute(place: MKPlacemark) {
        let destination = MKMapItem(placemark: place)
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let routeRequest = MKDirections(request: request)
        DispatchQueue.main.async {
            routeRequest.calculate { (res, err) in
                guard let response = res else {return}
                self.route = response.routes.first
                guard let polyline = self.route?.polyline else {return}
                self.mapView.addOverlay(polyline)
            }
        }
        
        
    }
    


    
    
}
