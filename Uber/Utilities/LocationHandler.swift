//
//  Locations.swift
//  Uber
//
//  Created by Marwan Osama on 11/30/20.
//

import Foundation
import CoreLocation
import MapKit


class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .authorizedWhenInUse && locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once") { _ in
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        } else if locationManager.authorizationStatus == .authorizedAlways && locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Allow 'Maps' to use your precise location once") { _ in
                self.locationManager.startUpdatingLocation()
            }
        } else if locationManager.accuracyAuthorization == .fullAccuracy {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            self.locationManager.stopUpdatingLocation()
//            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//            let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
//            mapView.setRegion(region, animated: true)
//            mapView.showsUserLocation = true
//            mapView.userTrackingMode = .follow
            
        }
    }
    
    func seachPlacesOnMap(query: String, completion: @escaping([MKPlacemark]?, Error?)-> Void) {
        guard let coordinations = self.locationManager.location?.coordinate else {return}
        let request = MKLocalSearch.Request()
        let coordinate = CLLocationCoordinate2D(latitude: coordinations.latitude, longitude: coordinations.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        request.region = region
        request.naturalLanguageQuery = query
        let search = MKLocalSearch.init(request: request)
        search.start { (res, err) in
            if err != nil {
                completion(nil,err)
            } else {
                var result: [MKPlacemark]
                guard let response = res else {return}
                result = response.mapItems.map { $0.placemark }
                completion(result,nil)
            }
        }
    }
    
    
}
