//
//  User.swift
//  Uber
//
//  Created by Marwan Osama on 11/30/20.
//

import Foundation
import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    
    init(uid:String, dictionary: [String:Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let accountIndex = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: accountIndex)!
        }
        
    }
    
}
