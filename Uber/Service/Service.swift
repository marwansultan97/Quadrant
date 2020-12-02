//
//  Service.swift
//  Uber
//
//  Created by Marwan Osama on 11/30/20.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let DRIVER_LOCATIONS_REF = DB_REF.child("driver-locations")

class Service {
    
    static let shared = Service()
        
    func fetchUserData(userID: String, completion: @escaping (User)-> Void) {
        REF_USERS.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
        
    }
    
    func fetchDriver(location: CLLocation, completion: @escaping(User)-> Void) {
        let geofire = GeoFire(firebaseRef: DRIVER_LOCATIONS_REF)
        
        DRIVER_LOCATIONS_REF.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(userID: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            }
            
            
            )}
        
        
    }
    
    
}
