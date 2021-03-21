//
//  SetupFavoritePlaceViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import MapKit


class SetupFavoritePlaceViewModel {
    
    let uid = Auth.auth().currentUser!.uid
    
    var placesBehavior = BehaviorRelay<[MKPlacemark]>(value: [])
    var isUpdateSuccess = BehaviorRelay<Bool>(value: false)
    
    func updateFavoritePlaces(placeType: FavoritePlaceUseCase, place: MKPlacemark) {
        let name = place.name
        let thoroughFare = place.thoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        
        let placeCoordinates = [place.coordinate.latitude, place.coordinate.longitude]
        
        let values: [String:Any] = ["placeCoordinates": placeCoordinates,
                                    "name": name ?? "",
                                    "thoroughFare": thoroughFare ?? "",
                                    "locality": locality ?? "",
                                    "adminArea": adminArea ?? ""]
        REF_FAVORITE_PLACES.child(uid).child(placeType.rawValue).updateChildValues(values) { [weak self] (err, ref) in
            if let err = err {
                print(err)
                return
            }
            self?.isUpdateSuccess.accept(true)
        }
    }
    

    func updateCurrentLocationAsFav(placeType: FavoritePlaceUseCase) {
        let geocoder = CLGeocoder()
        let location = HomePViewController.locationManager.location
        geocoder.reverseGeocodeLocation(location!) { [weak self] (placeMarks, err) in
            guard let self = self else { return }
            guard err == nil else {
                print("DEBUG: err geocoding \(err!.localizedDescription)")
                return
            }
            guard let place = placeMarks?.first else {return}
            guard let location = place.location else { return }
            let name = place.name
            let thoroughFare = place.thoroughfare
            let locality = place.locality
            let adminArea = place.administrativeArea
            
            let placeCoordinates = [location.coordinate.latitude, location.coordinate.longitude]
            
            let values: [String:Any] = ["placeCoordinates": placeCoordinates,
                                        "name": name ?? "",
                                        "thoroughFare": thoroughFare ?? "",
                                        "locality": locality ?? "",
                                        "adminArea": adminArea ?? ""]
            REF_FAVORITE_PLACES.child(self.uid).child(placeType.rawValue).updateChildValues(values) { (err, ref) in
                if let err = err {
                    print(err)
                    return
                }
                self.isUpdateSuccess.accept(true)
            }

        }
    }
    
    func seachPlacesOnMap(query: String) {
        guard let coordinations = HomePViewController.locationManager.location?.coordinate else {return}
        let request = MKLocalSearch.Request()
        let coordinate = CLLocationCoordinate2D(latitude: coordinations.latitude, longitude: coordinations.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        request.region = region
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (res, err) in
            if let err = err {
                print(err)
                return
            }
            guard let response = res else {return}
            let places = response.mapItems.map { $0.placemark }
            self?.placesBehavior.accept(places)
            
        }
    }
    
    
}
