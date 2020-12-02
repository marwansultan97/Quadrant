//
//  User.swift
//  Uber
//
//  Created by Marwan Osama on 11/30/20.
//

import Foundation
import CoreLocation

struct User {
    
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    let uid: String
    
    init(uid:String, dictionary: [String:Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
    
}
