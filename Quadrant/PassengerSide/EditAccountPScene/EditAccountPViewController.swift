//
//  EditAccountPViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/21/21.
//

import UIKit
import RxCocoa
import RxSwift
import Firebase

struct EditAccountOption {
    let title: String
    let value: String
    let handler: (()->())
}

class EditAccountPViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    
    private let cellIdentifier = "EditAccountsTableViewCell"
    private let bag = DisposeBag()
    private var userSubject = PublishSubject<User>()
    
    private var accountOptions = [EditAccountOption]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        fetchUser()
    }
    
    private func configureUI() {
        userSubject.subscribe(onNext: { [weak self] user in
            guard let self = self else { return }
            
            let firstchar = user.firstname.first!.lowercased()
            self.profileImageView.image = UIImage(named: "SF_\(firstchar)_circle")
            
            self.accountOptions = [
                EditAccountOption(title: "Firstname", value: user.firstname, handler: {
                    self.performSegue(withIdentifier: "EditFirstnameP", sender: self)
                }),
                EditAccountOption(title: "Surname", value: user.surname, handler: {
                    self.performSegue(withIdentifier: "EditSurnameP", sender: self)
                }),
                EditAccountOption(title: "Phone number", value: user.phonenumber, handler: {
                    self.performSegue(withIdentifier: "EditPhonenumberP", sender: self)
                }),
                EditAccountOption(title: "Password", value: "Change Password", handler: {
                    self.performSegue(withIdentifier: "EditPasswordP", sender: self)
                }),
                
            ]
            
            self.tableView.reloadData()
            
        }).disposed(by: bag)
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USERS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.userSubject.onNext(user)
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    
    
    
}

extension EditAccountPViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EditAccountsTableViewCell
        cell.titleLabel.text = accountOptions[indexPath.row].title
        cell.valueLabel.text = accountOptions[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        accountOptions[indexPath.row].handler()
    }
    
    
}
