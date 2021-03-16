//
//  EditSurnameController.swift
//  Uber
//
//  Created by Marwan Osama on 12/30/20.
//

import UIKit

class EditSurnameController: UIViewController {
    
    var user: User?
    let hud = ProgressHUD.shared
    
    var viewModel: EditAccountViewModel?
    
    init(user: User, viewModel: EditAccountViewModel) {
        self.viewModel = viewModel
        self.surnameTF.text = user.surname
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var surnameTF: UITextField = {
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        tf.isSecureTextEntry = false
        tf.backgroundColor = .systemBackground
        tf.defaultTextAttributes = [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var surnameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        label.text = "Surname"
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
        view.addSubview(surnameTF)
        view.addSubview(surnameLabel)
        view.addSubview(button)
        view.addSubview(separatorView)
        
        surnameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        surnameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        
        
        surnameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        surnameTF.topAnchor.constraint(equalTo: surnameLabel.bottomAnchor, constant: 20).isActive = true
        surnameTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        surnameTF.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        separatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        separatorView.topAnchor.constraint(equalTo: surnameTF.bottomAnchor, constant: 10).isActive = true
        separatorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        separatorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        
        button.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 30).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func showAlert(title: String, message: String, handler: @escaping((UIAlertAction)-> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func buttonTapped() {
        print("Handle surname change")
        guard let newSurname = surnameTF.text else {return}
        let value: [String:Any] = ["surname": newSurname]
        hud.show(message: "Please wait!")
        viewModel!.changeAccountValues(values: value) { (err, ref) in
            guard err == nil else {
                self.hud.dismiss()
                self.showAlert(title: "ERROR", message: "Something went wrong... please try again") { _ in
                }
                return
            }
            self.hud.dismiss()
            self.showAlert(title: "Success", message: "Changed Successfully") { _IOFBF in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}
