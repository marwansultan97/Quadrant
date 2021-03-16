//
//  SideMenuController.swift
//  Uber
//
//  Created by Marwan Osama on 12/22/20.
//




import UIKit
import Firebase
import SideMenuSwift
import TTGSnackbar
import Combine


class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var topViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
    
    var user: User? {
        didSet {
            guard user != nil else {return}
            fullNameLabel.text = "\(user!.firstname) \(user!.surname)"
            emailLabel.text = user!.email
            let firstChar = user?.firstname.first?.lowercased()
            profileImageView.image = UIImage(systemName: "\(firstChar!).circle")
            profileImageView.tintColor = .systemBackground
        }
    }

    var viewModel = MenuViewModel()
    var subscribtion = Set<AnyCancellable>()
        
    var models = [SettingsMenu]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        setSubscribtion()
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    //MARK: - UI Methods

        
    func configureUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.systemBackground.cgColor
        topViewWidth.constant = self.view.frame.width/4 * 3
        tableViewWidth.constant = self.view.frame.width/4 * 3
        fullNameLabel.adjustsFontSizeToFitWidth = true
        fullNameLabel.minimumScaleFactor = 0.5
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.5
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    
    func setSubscribtion() {
        subscribtion = [
            viewModel.$user.assign(to: \.user, on: self),
            //FIXME: - put model in vc not vm
            viewModel.$models.assign(to: \.models, on: self)
        ]
    }
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier, for: indexPath) as! MenuTableViewCell
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

