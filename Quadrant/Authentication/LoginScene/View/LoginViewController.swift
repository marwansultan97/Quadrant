//
//  LoginViewController.swift
//  Uber
//
//  Created by Marwan Osama on 3/13/21.
//

import UIKit
import RxSwift
import RxCocoa
import ChameleonFramework
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var emailIcon: UIImageView!
    @IBOutlet weak var passwordIcon: UIImageView!
    @IBOutlet weak var hidePasswordButton: UIButton!
    
    private let bag = DisposeBag()
    private var viewModel = LoginViewModel()
    
    private var isPasswordHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        logout()
        checkAuthenticatedUser()
        configureUI()
        setupEmailTextField()
        setupPasswordTextField()
        bindViewModel()
        loginButtonTapped()
        signupButtonTapped()
        hidePasswordButtonTapped()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    func logout() {
        Authentication.shared.signOut { (sucess, err) in
            if let err = err {
                print(err)
                return
            }
            print("UserLogged Out")
        }
    }
    
    private func checkAuthenticatedUser() {
        self.view.alpha = 0
        if Auth.auth().currentUser != nil {
            viewModel.fetchUserData()
        } else {
            self.view.alpha = 1
        }
    }
    
    
    
    private func configureUI() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        emailContainer.layer.borderColor = UIColor.gray.cgColor
        emailContainer.layer.borderWidth = 1
        emailContainer.layer.cornerRadius = emailContainer.frame.height / 2
        
        passwordContainer.layer.borderColor = UIColor.gray.cgColor
        passwordContainer.layer.borderWidth = 1
        passwordContainer.layer.cornerRadius = emailContainer.frame.height / 2
    }
    
    private func setupEmailTextField() {
        emailTF.rx.text.orEmpty.bind(to: viewModel.emailBehavior).disposed(by: bag)
        
        emailTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.emailContainer.layer.borderColor = UIColor(hexString: "C90000")?.cgColor
                self.emailIcon.tintColor = UIColor(hexString: "C90000")
            }
        }).disposed(by: bag)
        
        emailTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.emailContainer.layer.borderColor = UIColor.gray.cgColor
                self.emailIcon.tintColor = UIColor.gray
            }
        }).disposed(by: bag)
    }
    
    private func setupPasswordTextField() {
        passwordTF.rx.text.orEmpty.bind(to: viewModel.passwordBehavior).disposed(by: bag)
        
        passwordTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.passwordContainer.layer.borderColor = UIColor(hexString: "C90000")?.cgColor
                self.passwordIcon.tintColor = UIColor(hexString: "C90000")
            }
        }).disposed(by: bag)
        
        passwordTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.passwordContainer.layer.borderColor = UIColor.gray.cgColor
                self.passwordIcon.tintColor = UIColor.gray
            }
        }).disposed(by: bag)
    }
    
    private func bindViewModel() {
        viewModel.isLoadingBehavior.subscribe(onNext: { [weak self] isLoading in
            if isLoading {
                self?.showHUD(message: "Logging in... Please wait!")
            } else {
                self?.dismissHUD()
            }
        }).disposed(by: bag)
        
        viewModel.errorBehavior.filter({ !$0.isEmpty }).subscribe(onNext: { [weak self] err in
            self?.dismissHUD()
            self?.showError(message: err, dismissDelay: 3.5)
        }).disposed(by: bag)
        
        viewModel.userObservable.subscribe(onNext: { [weak self] user in
            if user.accountType == .passenger {
                let homeP = UIStoryboard(name: "HomeP", bundle: nil).instantiateInitialViewController()
                self?.navigationController?.pushViewController(homeP!, animated: true)
            } else {
                // Go To Driver Home VC
                let homeD = UIStoryboard(name: "HomeD", bundle: nil).instantiateInitialViewController()
                self?.navigationController?.pushViewController(homeD!, animated: true)
            }
            
        }).disposed(by: bag)
    }
    
    private func loginButtonTapped() {
        viewModel.isLoginButtonEnabled.subscribe(onNext: { (isEnabled) in
            self.loginButton.isEnabled = isEnabled
            self.loginButton.backgroundColor = isEnabled ? UIColor(hexString: "C90000") : UIColor(hexString: "C90000")?.darken(byPercentage: 0.2)
        }).disposed(by: bag)
        
        loginButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.loginEmail()
        }).disposed(by: bag)
    }
    
    private func signupButtonTapped() {
        signupButton.rx.tap.subscribe(onNext: {
            let signupVC = UIStoryboard(name: "Signup", bundle: nil).instantiateInitialViewController()
            self.navigationController?.pushViewController(signupVC!, animated: true)
        }).disposed(by: bag)
    }
    
    private func hidePasswordButtonTapped() {
        hidePasswordButton.rx.tap.subscribe(onNext: {
            self.passwordTF.isSecureTextEntry = self.isPasswordHidden ? true : false
            self.isPasswordHidden.toggle()
        }).disposed(by: bag)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    

}
