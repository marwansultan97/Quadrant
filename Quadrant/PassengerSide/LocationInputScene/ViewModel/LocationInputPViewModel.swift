//
//  LocationInputViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/14/21.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit
import Firebase

class LocationInputPViewModel {
    
    let uid = Auth.auth().currentUser?.uid
    
    var placesBehavior = BehaviorRelay<[MKPlacemark]>(value: [])
    var searchPlacesError = BehaviorRelay<String>(value: "")
    
    var homePlaceBehavior = BehaviorRelay<MKPlacemark?>(value: nil)
    var workPlaceBehavior = BehaviorRelay<MKPlacemark?>(value: nil)
    var isLoadingBehavior = BehaviorRelay<Bool>(value: false)
    
    var group: DispatchGroup?
    
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
    
    func fetchHomePlace() {
        isLoadingBehavior.accept(true)
        group = DispatchGroup()
        group?.enter()
        REF_FAVORITE_PLACES.child(uid!).child("Home").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {
                self.group?.leave()
                return
            }
            let place = FavoritePlace(values: dictionary)
            let homePlace = self.convertFavoritePlaceToPlaceMark(place: place)
            self.homePlaceBehavior.accept(homePlace)
            self.group?.leave()
        }
        
        group?.notify(queue: .main) {
            self.isLoadingBehavior.accept(false)
        }
    }
    
    func fetchWorkPlace() {
        group?.enter()
        REF_FAVORITE_PLACES.child(uid!).child("Work").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {
                self.group?.leave()
                return
            }
            let place = FavoritePlace(values: dictionary)
            let workPlace = self.convertFavoritePlaceToPlaceMark(place: place)
            self.workPlaceBehavior.accept(workPlace)
            self.group?.leave()
        }
    }
    
    
    func convertFavoritePlaceToPlaceMark(place: FavoritePlace) -> MKPlacemark  {
        let addressDictionary: [String:Any] = ["Name": place.name ?? "",
                                               "Thoroughfare": place.thoroughFare ?? "",
                                               "City": place.locality ?? "",
                                               "State": place.adminArea ?? ""]
        let placeMark = MKPlacemark(coordinate: place.placeCoordinates, addressDictionary: addressDictionary)
        return placeMark
    }
    
    
    
    
}
