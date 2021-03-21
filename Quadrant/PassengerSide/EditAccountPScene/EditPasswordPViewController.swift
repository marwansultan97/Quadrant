//
//  EditPasswordPViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/21/21.
//

import UIKit
import RxCocoa
import RxSwift
import Firebase

class EditPasswordPViewController: UIViewController {
    
    
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    

    private let bag = DisposeBag()
    
    private var oldPasswordBehavior = BehaviorRelay<String>(value: "")
    private var oldPasswordIsValid: Observable<Bool> {
        return oldPasswordBehavior.asObservable().map { text -> Bool in
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmedText.isEmpty
        }
    }
    
    
    
    private var newPasswordBehavior = BehaviorRelay<String>(value: "")
    private var newPasswordIsValid: Observable<Bool> {
        return newPasswordBehavior.asObservable().map { text -> Bool in
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmedText.isEmpty
        }
    }
    
    private var isButtonEnabled: Observable<Bool> {
        return Observable.combineLatest(oldPasswordIsValid, newPasswordIsValid) { (oldPasswordIsValid, newPasswordIsValid) in
            return oldPasswordIsValid && newPasswordIsValid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSaveButton()
        
    }
    

    private func configureSaveButton() {
        oldPasswordTF.rx.text.orEmpty.bind(to: oldPasswordBehavior).disposed(by: bag)
        newPasswordTF.rx.text.orEmpty.bind(to: newPasswordBehavior).disposed(by: bag)
        
        isButtonEnabled.subscribe(onNext: { [weak self] isEnabled in
            if isEnabled {
                self?.saveButton.isEnabled = true
                self?.saveButton.backgroundColor = UIColor(hexString: "C90000")
            } else {
                self?.saveButton.isEnabled = false
                self?.saveButton.backgroundColor = UIColor(hexString: "C90000")?.darken(byPercentage: 0.2)
            }
        }).disposed(by: bag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let oldPassword = self?.oldPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                guard let newPassword = self?.newPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                print(oldPassword,newPassword)
            }).disposed(by: bag)
        
        
    }
    
    func changePassword(email: String, oldPassword: String, newPassword: String, completion: @escaping(Error?)-> Void) {
        showHUD(message: nil)
        guard let user = Auth.auth().currentUser ,
              let email = Auth.auth().currentUser?.email else { return }
        
        var credential: AuthCredential
        
        credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        user.reauthenticate(with: credential, completion: { [weak self] (res, err) in
            guard let self = self else { return }
            if let err = err {
                print("DEBUG: err credential \(err)")
                self.dismissHUD()
                self.showError(message: "Something went wrong... Please try again!", dismissDelay: 2)
            }
            print("DEBUG: credential is \(credential)")
            user.updatePassword(to: newPassword) { (err) in
                if let err = err {
                    print("err updating Password \(err)")
                    self.dismissHUD()
                    self.showError(message: "Something went wrong... Please try again!", dismissDelay: 2)
                    return
                }
                self.dismissHUD()
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

}
