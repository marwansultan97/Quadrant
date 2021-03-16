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
    
    let firstname: String
    let surname: String
    let email: String
    let phonenumber: String
    let password: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    
    init(uid:String, dictionary: [String:Any]) {
        self.uid = uid
        self.firstname = dictionary["firstname"] as? String ?? ""
        self.surname = dictionary["surname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.password = dictionary["password"] as? String ?? ""
        self.phonenumber = dictionary["phonenumber"] as? String ?? ""
        
        if let accountIndex = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: accountIndex)!
        }
        
    }
    
}
