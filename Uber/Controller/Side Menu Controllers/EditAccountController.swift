//
//  EditAccountController.swift
//  Uber
//
//  Created by Marwan Osama on 12/22/20.
//

struct EditAccountOptions {
    let mainLabel: String
    let secondaryLabel: String
    let handler: (()-> Void)
}


import UIKit
import Firebase

class EditAccountController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    var models = [EditAccountOptions]()
    var user: User? {
        didSet {
            configureUI()
            configureAccountEditingCellModels()
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        fetchUser()
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(userID: uid) { (user) in
            self.user = user
        }
    }
    
    //MARK: UI Methods
    func configureUI() {
        let firstChar = user?.firstname.first?.lowercased()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.image = UIImage(systemName: "\(firstChar!).circle")
        profileImageView.tintColor = .label
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
    }
    
    func configureAccountEditingCellModels() {
        self.models = [
            EditAccountOptions(mainLabel: "First name", secondaryLabel: user!.firstname, handler: {
                let vc = EditFirstnameController(user: self.user!)
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            EditAccountOptions(mainLabel: "Surname", secondaryLabel: user!.surname, handler: {
                let vc = EditSurnameController(user: self.user!)
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            EditAccountOptions(mainLabel: "Phone number", secondaryLabel: user!.phonenumber, handler: {
                let vc = EditPhonenumberController(user: self.user!)
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            EditAccountOptions(mainLabel: "Email", secondaryLabel: user!.email, handler: {
                let vc = EditEmailController(user: self.user!)
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            EditAccountOptions(mainLabel: "Password", secondaryLabel: String(user!.password.map({ _ in return "*" })), handler: {
                let vc = EditPasswordController(user: self.user!)
                self.navigationController?.pushViewController(vc, animated: true)
            })
        ]
    }
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditAccountTableViewCell.identifier, for: indexPath) as! EditAccountTableViewCell
        let model = models[indexPath.row]
        cell.configureCell(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.row]
        model.handler()
    }

}
