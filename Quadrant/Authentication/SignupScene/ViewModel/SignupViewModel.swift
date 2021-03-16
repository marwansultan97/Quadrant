//
//  SignupViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 3/13/21.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase


class SignupViewModel {
    
    
    var errorBehavior = BehaviorRelay<String>(value: "")
    var isLoadingBehavior = BehaviorRelay<Bool>(value: false)
    
    private var userSubject = PublishSubject<User>()
    var userObservable: Observable<User> {
        return userSubject.asObservable()
    }
    
    
    var emailBehavior = BehaviorRelay<String>(value: "")
    var passwordBehavior = BehaviorRelay<String>(value: "")
    var firstnameBehavior = BehaviorRelay<String>(value: "")
    var surnameBehavior = BehaviorRelay<String>(value: "")
    var phonenumberBehavior = BehaviorRelay<String>(value: "")
    var accountTypeBehavior = BehaviorRelay<Int>(value: 0)
    
    
    var isValidEmail: Observable<Bool> {
        return emailBehavior.asObservable().map { (email) -> Bool in
            let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            
            let emailValid = emailPred.evaluate(with: emailTrimmed) && !emailTrimmed.isEmpty
            
            return emailValid
        }
    }
    
    var isValidPassword: Observable<Bool> {
        return passwordBehavior.asObservable().map { (password) -> Bool in
            let passwordTrimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
            return !passwordTrimmed.isEmpty
        }
    }
    
    var isValidFirstname: Observable<Bool> {
        return firstnameBehavior.asObservable().map { (firstname) -> Bool in
            let firstnameTrimmed = firstname.trimmingCharacters(in: .whitespacesAndNewlines)
            return !firstnameTrimmed.isEmpty
        }
    }
    var isValidSurname: Observable<Bool> {
        return surnameBehavior.asObservable().map { (surname) -> Bool in
            let surnameTrimmed = surname.trimmingCharacters(in: .whitespacesAndNewlines)
            return !surnameTrimmed.isEmpty
        }
    }
    var isValidPhonenumber: Observable<Bool> {
        return phonenumberBehavior.asObservable().map { (phonenumber) -> Bool in
            let phonenumberTrimmed = phonenumber.trimmingCharacters(in: .whitespacesAndNewlines)
            return !phonenumberTrimmed.isEmpty
        }
    }
    
    var isSignupButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(isValidEmail, isValidPassword, isValidFirstname, isValidSurname, isValidPhonenumber) { validEmail, validPassword, validFirstname, validSurname, validPhonenumber in
            return validEmail && validPassword && validFirstname && validSurname && validPhonenumber
            
        }
    }
    
    func signupEmail() {
        // Sign up new user
        
        isLoadingBehavior.accept(true)
        Auth.auth().createUser(withEmail: emailBehavior.value, password: passwordBehavior.value) { [weak self] (res, err) in
            guard let self = self else { return }
            if let err = err {
                print("err creating user \(err))")
                self.errorBehavior.accept("\(err.localizedDescription)")
                return
            }
            guard let uid = res?.user.uid else {return}
            
            // Save Some User's Data to Fetch it on the next openings of the application
            
            let values: [String:Any] = ["email": self.emailBehavior.value,
                                        "firstname": self.firstnameBehavior.value,
                                        "surname": self.surnameBehavior.value,
                                        "phonenumber": self.phonenumberBehavior.value,
                                        "accountType": self.accountTypeBehavior.value]
            
            REF_USERS.child(uid).updateChildValues(values) { [weak self] (err, ref) in
                guard let self = self else { return }
                if let err = err {
                    print("error saving data \(err)")
                    self.errorBehavior.accept("\(err.localizedDescription)")
                    return
                }
                
                // Now we get the data we just saved and construct "USER" and once we get the user we send him to Home View Controller based on "Passenger" or "Driver"
                
                REF_USERS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
                    guard let self = self else { return }
                    guard let dictionary = snapshot.value as? [String:Any] else {return}
                    let uid = snapshot.key
                    let user = User(uid: uid, dictionary: dictionary)
                    self.isLoadingBehavior.accept(false)
                    self.userSubject.onNext(user)
                }
                
            }
        }
    }

    
    
    
    
    
    
    
}
