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
import Combine

class EditAccountController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var viewModel = EditAccountViewModel()
    var subscribtion = Set<AnyCancellable>()
    
    var models = [EditAccountOptions]()
    var user: User? {
        didSet {
            guard user != nil else {return}
            configureUI()
            configureAccountEditingCellModels()
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setSubscribtion()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        viewModel.fetchMyData()
    }
    
    
    
    func setSubscribtion() {
        subscribtion = [
            viewModel.$user.assign(to: \.user, on: self)
        ]
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
            EditAccountOptions(mainLabel: "First name".localize, secondaryLabel: user!.firstname, handler: {
                self.pushViewController(viewCont: EditFirstnameController(user: self.user!, viewModel: self.viewModel))
            }),
            EditAccountOptions(mainLabel: "Surname".localize, secondaryLabel: user!.surname, handler: {
                self.pushViewController(viewCont: EditSurnameController(user: self.user!, viewModel: self.viewModel))
            }),
            EditAccountOptions(mainLabel: "Phone number".localize, secondaryLabel: user!.phonenumber, handler: {
                self.pushViewController(viewCont: EditPhonenumberController(user: self.user!, viewModel: self.viewModel))
            }),
            EditAccountOptions(mainLabel: "Email".localize, secondaryLabel: user!.email, handler: {
                self.pushViewController(viewCont: EditEmailController(user: self.user!, viewModel: self.viewModel))
            }),
            EditAccountOptions(mainLabel: "Password".localize, secondaryLabel: String(user!.password.map({ _ in return "*" })), handler: {
                self.pushViewController(viewCont: EditPasswordController(user: self.user!, viewModel: self.viewModel))
            })
        ]
    }
    
    func pushViewController(viewCont: UIViewController) {
        let vc = viewCont
        self.navigationController?.pushViewController(vc, animated: true)
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

