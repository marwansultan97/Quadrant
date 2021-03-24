//
//  LoginViewController.swift
//  Uber
//
//  Created by Marwan Osama on 3/13/21.

import UIKit
import RxSwift
import RxCocoa
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
        
        removeAllPreviousVCInNavigationStack()
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
    
    
    //MARK: - UI Configurations
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
                self.emailContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.emailIcon.image = UIImage(named: "SF_envelope_open_fill-1")
            }
        }).disposed(by: bag)
        
        emailTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.emailContainer.layer.borderColor = UIColor.gray.cgColor
                self.emailIcon.image = UIImage(named: "SF_envelope_open_fill")
            }
        }).disposed(by: bag)
    }
    
    private func setupPasswordTextField() {
        passwordTF.rx.text.orEmpty.bind(to: viewModel.passwordBehavior).disposed(by: bag)
        
        passwordTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.passwordContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.passwordIcon.image = UIImage(named: "SF_lock_circle-1")
            }
        }).disposed(by: bag)
        
        passwordTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: {
            UIView.animate(withDuration: 0.5) {
                self.passwordContainer.layer.borderColor = UIColor.gray.cgColor
                self.passwordIcon.image = UIImage(named: "SF_lock_circle")
            }
        }).disposed(by: bag)
    }
    
    //MARK: - ViewModel Binding
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
                let homeD = UIStoryboard(name: "HomeD", bundle: nil).instantiateInitialViewController()
                self?.navigationController?.pushViewController(homeD!, animated: true)
            }
            
        }).disposed(by: bag)
    }
    
    //MARK: - Buttons Configurations
    private func loginButtonTapped() {
        viewModel.isLoginButtonEnabled.subscribe(onNext: { (isEnabled) in
            self.loginButton.isEnabled = isEnabled
            self.loginButton.backgroundColor = isEnabled ? UIColor(rgb: 0xEB0000) : UIColor(rgb: 0x600000)
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
