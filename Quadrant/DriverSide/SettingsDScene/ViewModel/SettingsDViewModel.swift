//
//  SettingsDViewModel.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/21/21.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class SettingsDViewModel {
    
    let uid = Auth.auth().currentUser!.uid
    
    var isLoadingBehavior = BehaviorRelay<Bool>(value: false)
    
    var userBehavior = BehaviorRelay<User?>(value: nil)

    func fetchUser() {
        
        isLoadingBehavior.accept(true)
        REF_USERS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.userBehavior.accept(user)
            self.isLoadingBehavior.accept(false)
        }
    }
    
}
