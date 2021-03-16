//
//  LoginController.swift
//  Uber
//
//  Created by Marwan Osama on 11/21/20.
//


import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    let hud = ProgressHUD.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        checkAuth()
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(endTextEditing)))
        

    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = emailTF.text else {return}
        guard let password = passwordTF.text else {return}
        hud.show(message: "Logging in...")
        Authentication.shared.loginEmail(email: email, password: password) { (isSuccess, err) in
            if isSuccess {
                // GO TO HOME SCREEN
                self.hud.dismiss()
                self.performSegue(withIdentifier: "HomeController", sender: self)
            } else {
                self.hud.dismiss()
                self.showAlert(message: err!.localizedDescription)
            }
        }
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
    
    func checkAuth() {
        self.view.alpha = 0
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "HomeController", sender: self)
        } else {
            self.view.alpha = 1
        }
    }


}
