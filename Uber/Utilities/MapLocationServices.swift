//
//  MapKit.swift
//  Uber
//
//  Created by Marwan Osama on 12/4/20.
//

import Foundation
import MapKit
import CoreLocation

class MapLocationServices {
    
    static let shared = MapLocationServices()
    
    let locationManager = CLLocationManager()
    
        
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
    
    func showRoute(destination: MKPlacemark, completion: @escaping(MKDirections.Response?, Error?)-> Void) {
        let request = MKDirections.Request()
        guard let currentCoordinations = self.locationManager.location?.coordinate else {return}
        let sourceCoordinations = CLLocationCoordinate2D(latitude: currentCoordinations.latitude, longitude: currentCoordinations.longitude)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinations)
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        
        let routeRequest = MKDirections(request: request)
        routeRequest.calculate { (res, err) in
            guard let response = res else {return}
            completion(response,nil)
            
        }
    }

}


