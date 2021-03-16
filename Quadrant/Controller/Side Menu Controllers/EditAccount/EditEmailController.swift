//
//  EditEmailController.swift
//  Uber
//
//  Created by Marwan Osama on 12/30/20.
//

import UIKit


class EditEmailController: UIViewController {
    
    var user: User?
    let hud = ProgressHUD.shared
    
    var viewModel: EditAccountViewModel?
    
    init(user: User, viewModel: EditAccountViewModel) {
        self.viewModel = viewModel
        self.user = user
        emailTF.text = user.email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var emailTF: UITextField = {
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        tf.isSecureTextEntry = false
        tf.adjustsFontSizeToFitWidth = true
        tf.backgroundColor = .systemBackground
        tf.defaultTextAttributes = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var emailLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        label.text = "Email"
        label.alpha = 0.7
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let attributes = NSAttributedString(string: "SAVE", attributes: [NSAttributedString.Key.foregroundColor : UIColor.systemBackground, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 30)!])
        button.backgroundColor = .label
        button.layer.cornerRadius = 10
        button.setAttributedTitle(attributes, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        handleUIandLayout()
    }
    

    func handleUIandLayout() {
        view.addSubview(emailTF)
        view.addSubview(emailLabel)
        view.addSubview(button)
        view.addSubview(separatorView)
        
        emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        
        
        emailTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        emailTF.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20).isActive = true
        emailTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        emailTF.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        separatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        separatorView.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 10).isActive = true
        separatorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        separatorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        
        button.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 30).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func showAlert(title: String, message: String, handler: @escaping(UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func buttonTapped() {
        print("Handle email change")
        guard let newEmail = emailTF.text else {return}
        hud.show(message: "Please wait!".localize)
        viewModel!.changeEmail(email: newEmail, password: user!.password) { (err) in
            guard err == nil else {
                self.hud.dismiss()
                self.showAlert(title: "ERROR".localize, message: "Something went wrong... please try again".localize) { _ in
                }
                return
            }
            self.hud.dismiss()
            self.showAlert(title: "Success!".localize, message: "Changes Successfully".localize) { _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}
