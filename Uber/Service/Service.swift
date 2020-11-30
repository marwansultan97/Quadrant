//
//  Service.swift
//  Uber
//
//  Created by Marwan Osama on 11/30/20.
//

import Foundation
import Firebase
import FirebaseDatabase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

class Service {
    
    static let shared = Service()
    let userID = Auth.auth().currentUser?.uid
    
    func fetchUserData() {
        
        REF_USERS.child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let fullname = dictionary["fullname"] as? String else {return}
            print("DEBUG: \(fullname)")
        }
        
    }
    
    
    
    
    
}
