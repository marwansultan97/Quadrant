//
//  LoginViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 3/13/21.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase


class LoginViewModel {
    
    var errorBehavior = BehaviorRelay<String>(value: "")
    var isLoadingBehavior = BehaviorRelay<Bool>(value: false)
    
    private var userSubject = PublishSubject<User>()
    var userObservable: Observable<User> {
        return userSubject.asObservable()
    }
    
    var emailBehavior = BehaviorRelay<String>(value: "")
    var passwordBehavior = BehaviorRelay<String>(value: "")
    
    
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
    
    var isLoginButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(isValidEmail, isValidPassword) { passwordValid, emailValid in
            return passwordValid && emailValid
        }
    }
    
    func loginEmail() {
        isLoadingBehavior.accept(true)
        
        Auth.auth().signIn(withEmail: emailBehavior.value, password: passwordBehavior.value) { [weak self] (res, err) in
            guard let self = self else { return }
            if let err = err {
                print("error log in \(err)")
                self.errorBehavior.accept(err.localizedDescription)
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
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
