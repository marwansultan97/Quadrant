//
//  HomePViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/15/21.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class HomePViewModel {
    
    
    var routeBehavior = BehaviorRelay<MKRoute?>(value: nil)
    
    
    func showRoute(destination: MKPlacemark, locationManager: CLLocationManager) {
        let request = MKDirections.Request()
        guard let currentCoordinations = locationManager.location?.coordinate else {return}
        
        let sourceCoordinations = CLLocationCoordinate2D(latitude: currentCoordinations.latitude, longitude: currentCoordinations.longitude)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinations)
        
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        
        let routeRequest = MKDirections(request: request)
        
        routeRequest.calculate { [weak self] (response, err) in
            guard let route = response?.routes.first else { return }
            self?.routeBehavior.accept(route)
        }
    }
    
}
