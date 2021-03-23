//
//  EditPhonenumberPViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/21/21.
//

import UIKit
import RxCocoa
import RxSwift
import Firebase

class EditPhonenumberPViewController: UIViewController {

    
    @IBOutlet weak var phonenumberTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSaveButton()
        
    }
    

    private func configureSaveButton() {
        
        phonenumberTF.rx.text.orEmpty
            .map({ (text) -> String in
                let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedText
            })
            .subscribe(onNext: { [weak self] text in
                if text.isEmpty {
                    self?.saveButton.isEnabled = false
                    self?.saveButton.backgroundColor = UIColor(rgb: 0x600000)
                } else {
                    self?.saveButton.isEnabled = true
                    self?.saveButton.backgroundColor = UIColor(rgb: 0xEB0000)
                }
            }).disposed(by: bag)
        
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let text = self?.phonenumberTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                self?.changeAccountPhonenumber(phonenumber: text)
            }).disposed(by: bag)
    }
    
    func changeAccountPhonenumber(phonenumber: String) {
        self.showHUD(message: nil)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["phonenumber": phonenumber]
        REF_USERS.child(uid).updateChildValues(values) { [weak self] (err, ref) in
            if let err = err {
                print(err)
                self?.showError(message: "Something went wrong... Please try again!", dismissDelay: 2)
                return
            }
            self?.dismissHUD()
            self?.navigationController?.popViewController(animated: true)
            
        }
    }

}
