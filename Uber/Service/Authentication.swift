//
//  Authentication.swift
//  Uber
//
//  Created by Marwan Osama on 11/23/20.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import GeoFire

class Authentication {
    
    static let shared = Authentication()
    
    func loginEmail(email: String, password: String, completion: @escaping ( _ success: Bool, _ error: Error?)->()) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("error log in \(err)")
                completion(false,err)
                return
            }
            completion(true,nil)
        }
    }
    
    func signupEmail(email: String, password: String, values: [String:Any], accountType: Int, completion: @escaping ( _ success: Bool, _ error: Error?)->()) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("err creating user \(String(describing: err))")
                completion(false, err)
                return
            }
            guard let uid = res?.user.uid else {return}
            
            REF_USERS.child(uid).updateChildValues(values) { (err, ref) in
                if err != nil {
                    print("error saving data \(String(describing: err))")
                    completion(false,err)
                    return
                }
            }
            completion(true,nil)
        }
    }
    
    
    func signOut(completion: ( _ success: Bool, _ error: Error?)->()) {
        do {
            try Auth.auth().signOut()
            completion(true,nil)
        } catch let err {
            completion(false,err)
        }
    }

    
    
    
    
    
}
