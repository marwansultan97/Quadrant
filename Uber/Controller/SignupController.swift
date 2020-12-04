//
//  SignupController.swift
//  Uber
//
//  Created by Marwan Osama on 11/22/20.
//

import UIKit
import FirebaseAuth

class SignupController: UIViewController {
    
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var fullnameTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(endTextEditing)))
        
        
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTF.text else {return}
        guard let password = passwordTF.text else {return}
        guard let fullname = fullnameTF.text else {return}
        let accountType: Int = segmentedControl.selectedSegmentIndex
        
        let values: [String:Any] = ["email": email, "password": password, "fullname": fullname, "accountType": accountType]
        
        Authentication.shared.signupEmail(email: email, password: password, values: values, accountType: accountType) { [self] (isSuccess, err) in
            if isSuccess{
                // GO TO HOME SCREEN
                performSegue(withIdentifier: "HomeController", sender: self)
            }else{
                self.showAlert(message: err!.localizedDescription)
            }
        }
        
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController.init(title: "error", message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func endTextEditing() {
        view.endEditing(true)
    }
    
    
    
}
