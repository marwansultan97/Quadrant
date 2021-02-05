//
//  SearchFavoritePlacesViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/9/21.
//

import Foundation
import Firebase
import MapKit


class SearchFavoritePlacesViewModel {
    
    let uid = Auth.auth().currentUser?.uid ?? ""
    let services = Service.shared
    
    
    
    func updateFavoritePlaces(placeType: String, place: MKPlacemark, completion: @escaping(Error?, DatabaseReference) -> Void ) {
        
        services.updateFavoritePlaces(uid: uid, placeType: placeType, place: place, completion: completion)
        
    }
    
    
}
