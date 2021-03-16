//
//  LocationInputViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/8/21.
//

import Foundation
import MapKit
import CoreLocation
import Firebase
import Combine


class LocationInputViewModel {
    
    @Published var homePlace: MKPlacemark?
    @Published var workPlace: MKPlacemark?
    
    let uid = Auth.auth().currentUser?.uid ?? ""
    let services = Service.shared
    
    init() {
        fetchHomePlace()
        fetchWorkPlace()
    }
    
    func fetchHomePlace() {
        services.fetchFavouritePlaces(uid: uid, childName: "Home") { [weak self] (home) in
            guard let self = self else {return}
            let homePlaceMark = self.convertFavoritePlaceToPlaceMark(place: home)
            self.homePlace = homePlaceMark
        }
    }
    
    func fetchWorkPlace() {
        services.fetchFavouritePlaces(uid: uid, childName: "Work") { [weak self] (work) in
            guard let self = self else {return}
            let workPlaceMark = self.convertFavoritePlaceToPlaceMark(place: work)
            self.workPlace = workPlaceMark
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
