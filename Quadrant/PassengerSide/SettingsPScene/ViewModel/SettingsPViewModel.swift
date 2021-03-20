//
//  SettingsPViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import MapKit

class SettingsPViewModel {
    
    let uid = Auth.auth().currentUser!.uid
    
    var userBehavior = BehaviorRelay<User?>(value: nil)
    var homePlaceBehavior = BehaviorRelay<MKPlacemark?>(value: nil)
    var workPlaceBehavior = BehaviorRelay<MKPlacemark?>(value: nil)
    var isLoadingBehavior = BehaviorRelay<Bool>(value: false)
    
    private var group: DispatchGroup?
    
    
    
    func fetchUser() {
        isLoadingBehavior.accept(true)
        group = DispatchGroup()
        group?.enter()
        REF_USERS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.userBehavior.accept(user)
            self.group?.leave()
        }
        
        group?.notify(queue: .main) {
            print("fetched all data")
            self.isLoadingBehavior.accept(false)
        }
    }
    
    func fetchHomePlace() {
        group?.enter()
        REF_FAVORITE_PLACES.child(uid).child("Home").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {
                print("HomePLace is not here")
                self.group?.leave()
                return
            }
            let place = FavoritePlace(values: dictionary)
            let homePlace = self.convertFavoritePlaceToPlaceMark(place: place)
            self.homePlaceBehavior.accept(homePlace)
            print("HomePLace here")
            self.group?.leave()
        }
    }
    
    
    
    func fetchWorkPlace() {
        group?.enter()
        REF_FAVORITE_PLACES.child(uid).child("Work").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {
                print("WorkPlace is not here")
                self.group?.leave()
                return
            }
            let place = FavoritePlace(values: dictionary)
            let workPlace = self.convertFavoritePlaceToPlaceMark(place: place)
            self.workPlaceBehavior.accept(workPlace)
            print("WorkPLACE here")
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
