//
//  SignupViewController.swift
//  Uber
//
//  Created by Marwan Osama on 3/13/21.
//

import UIKit
import RxSwift
import RxCocoa

class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var firstnameContainer: UIView!
    @IBOutlet weak var surnameContainer: UIView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var phonenumberContainer: UIView!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var accountTypeContainer: UIView!
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var firstnameIcon: UIImageView!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var surnameIcon: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailIcon: UIImageView!
    @IBOutlet weak var phonenumberTF: UITextField!
    @IBOutlet weak var phonenumberIcon: UIImageView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordIcon: UIImageView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var hidePasswordButton: UIButton!
    
    
    private let bag = DisposeBag()
    private lazy var viewModel: SignupViewModel = {
        return SignupViewModel()
    }()
    
    private var isPasswordHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setupEmailTextField()
        setupPasswordTextField()
        setupFirstnameTextField()
        setupSurnameTextField()
        setupPhonenumberTextField()
        setupSegmentedControl()
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
        
        firstnameContainer.layer.borderColor = UIColor.gray.cgColor
        firstnameContainer.layer.borderWidth = 1
        firstnameContainer.layer.cornerRadius = emailContainer.frame.height / 2
        
        surnameContainer.layer.borderColor = UIColor.gray.cgColor
        surnameContainer.layer.borderWidth = 1
        surnameContainer.layer.cornerRadius = emailContainer.frame.height / 2
        
        phonenumberContainer.layer.borderColor = UIColor.gray.cgColor
        phonenumberContainer.layer.borderWidth = 1
        phonenumberContainer.layer.cornerRadius = emailContainer.frame.height / 2
        
        accountTypeContainer.layer.borderColor = UIColor.gray.cgColor
        accountTypeContainer.layer.borderWidth = 1
        accountTypeContainer.layer.cornerRadius = emailContainer.frame.height / 2
    }
    
    private func setupEmailTextField() {
        emailTF.rx.text.orEmpty.bind(to: viewModel.emailBehavior).disposed(by: bag)
        
        emailTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.emailContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.emailIcon.image = UIImage(named: "SF_envelope_open_fill-1")
            }
        }).disposed(by: bag)
        
        emailTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.emailContainer.layer.borderColor = UIColor.gray.cgColor
                self.emailIcon.image = UIImage(named: "SF_envelope_open_fill")
            }
        }).disposed(by: bag)
    }
    
    private func setupPasswordTextField() {
        passwordTF.rx.text.orEmpty.bind(to: viewModel.passwordBehavior).disposed(by: bag)
        
        passwordTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.passwordContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.passwordIcon.image = UIImage(named: "SF_lock_circle-1")
            }
        }).disposed(by: bag)
        
        passwordTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.passwordContainer.layer.borderColor = UIColor.gray.cgColor
                self.passwordIcon.image = UIImage(named: "SF_lock_circle")
            }
        }).disposed(by: bag)
    }
    
    private func setupFirstnameTextField() {
        firstnameTF.rx.text.orEmpty.bind(to: viewModel.firstnameBehavior).disposed(by: bag)
        
        firstnameTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.firstnameContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.firstnameIcon.image = UIImage(named: "SF_person_icloud_fill-1")
            }
        }).disposed(by: bag)
        
        firstnameTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.firstnameContainer.layer.borderColor = UIColor.gray.cgColor
                self.firstnameIcon.image = UIImage(named: "SF_person_icloud_fill")
            }
        }).disposed(by: bag)
    }
    
    private func setupSurnameTextField() {
        surnameTF.rx.text.orEmpty.bind(to: viewModel.surnameBehavior).disposed(by: bag)
        
        surnameTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.surnameContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.surnameIcon.image = UIImage(named: "SF_person-1")
            }
        }).disposed(by: bag)
        
        surnameTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.surnameContainer.layer.borderColor = UIColor.gray.cgColor
                self.surnameIcon.image = UIImage(named: "SF_person")
            }
        }).disposed(by: bag)
    }
    private func setupPhonenumberTextField() {
        phonenumberTF.rx.text.orEmpty.bind(to: viewModel.phonenumberBehavior).disposed(by: bag)
        
        phonenumberTF.rx.text.orEmpty
            .map { (text) in
                return text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            }.subscribe(onNext: { [weak self] text in
                self?.phonenumberTF.text = text
            }).disposed(by: bag)
        
        phonenumberTF.rx.controlEvent(.editingDidBegin).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.phonenumberContainer.layer.borderColor = UIColor(rgb: 0xEB0000).cgColor
                self.phonenumberIcon.image = UIImage(named: "SF_phone_fill-1")
            }
        }).disposed(by: bag)
        
        phonenumberTF.rx.controlEvent(.editingDidEnd).asControlEvent().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.phonenumberContainer.layer.borderColor = UIColor.gray.cgColor
                self.phonenumberIcon.image = UIImage(named: "SF_phone_fill")
            }
        }).disposed(by: bag)
    }
    
    //MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.isLoadingBehavior.subscribe(onNext: { [weak self] isLoading in
            if isLoading {
                self?.showHUD(message: "Signing up... Please wait!")
            } else {
                self?.dismissHUD()
            }
        }).disposed(by: bag)
        
        viewModel.errorBehavior.filter({ !$0.isEmpty }).subscribe(onNext: { [weak self] err in
            self?.dismissHUD()
            self?.showError(message: err, dismissDelay: 3.5)
        }).disposed(by: bag)
        
        viewModel.userObservable.subscribe(onNext: { [weak self] user in
            self?.showSuccess(message: "Signed up Successfully", dismissDelay: 1)
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
    private func setupSegmentedControl() {
        segmentedControl.rx.selectedSegmentIndex.bind(to: viewModel.accountTypeBehavior).disposed(by: bag)
    }
    
    private func signupButtonTapped() {
        viewModel.isSignupButtonEnabled.subscribe(onNext: { [weak self] (isEnabled) in
            guard let self = self else { return }
            self.signupButton.isEnabled = isEnabled
            self.signupButton.backgroundColor = isEnabled ? UIColor(rgb: 0xEB0000) : UIColor(rgb: 0x600000)
        }).disposed(by: bag)
        
        signupButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.signupEmail()
        }).disposed(by: bag)
    }
    
    
    
    
    private func loginButtonTapped() {
        
        loginButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
    }
    
    
    
    private func hidePasswordButtonTapped() {
        
        hidePasswordButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.passwordTF.isSecureTextEntry = self.isPasswordHidden ? true : false
            self.isPasswordHidden.toggle()
        }).disposed(by: bag)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

}
