//
//  EditAccountViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/9/21.
//




import UIKit
import Firebase
import Combine


class EditAccountViewModel {
    
    @Published var user: User?
    
    var services = Service.shared
    let uid = Auth.auth().currentUser?.uid ?? ""
    

    func fetchMyData() {
        services.fetchUserData(userID: uid) { (user) in
            self.user = user
        }
    }
    
    func changeAccountValues(values: [String:Any], completion: @escaping(Error?, DatabaseReference)-> Void) {
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func changeEmail(email: String, password: String, completion: @escaping(Error?)-> Void) {
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        credential = EmailAuthProvider.credential(withEmail: user!.email!, password: password)
        user?.reauthenticate(with: credential, completion: { (res, err) in
            if let err = err {
                print("DEBUG: err credential \(err.localizedDescription)")
            }
            print("DEBUG: credential is \(credential.provider)")
            Auth.auth().currentUser?.updateEmail(to: email, completion: completion)
            REF_USERS.child(self.uid).updateChildValues(["email": email])
            
        })
    }
    
    func changePassword(email: String, oldPassword: String, newPassword: String, completion: @escaping(Error?)-> Void) {
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        credential = EmailAuthProvider.credential(withEmail: user!.email!, password: oldPassword)
        user?.reauthenticate(with: credential, completion: { (res, err) in
            if let err = err {
                print("DEBUG: err credential \(err.localizedDescription)")
            }
            print("DEBUG: credential is \(credential)")
            Auth.auth().currentUser?.updatePassword(to: newPassword, completion: completion)
            REF_USERS.child(self.uid).updateChildValues(["password": newPassword])
        })
    }
    

}
