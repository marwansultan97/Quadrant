//
//  SideMenuDViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/16/21.
//

import UIKit
import RxCocoa
import RxSwift
import Firebase
import ChameleonFramework

class SideMenuDViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var profileView: UIView!
    

    private let cellIdentifier = "SideMenuTableViewCell"
    private let bag = DisposeBag()
    
    private var settingsCells = [SettingsMenu]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserData()
        configureUI()
        configureTableView()
        configureSettingsCells()
    }
    
    private func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.profileNameLabel.text = "\(user.firstname) \(user.surname)"
            self.profileEmailLabel.text = user.email
            let firstChar = user.firstname.first?.lowercased()
            self.profileImageView.image = UIImage(systemName: "\(firstChar!).circle")
        }
    }
    

    private func configureUI() {
        sideMenuWidth.constant = self.view.frame.width/4 * 3
        profileView.backgroundColor = UIColor(gradientStyle: .leftToRight,
                                              withFrame: profileView.frame,
                                              andColors: [FlatOrangeDark().darken(byPercentage: 0.1)!,                                         FlatOrange().darken(byPercentage: 0.1)!])
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderWidth = 1.5
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileNameLabel.adjustsFontSizeToFitWidth = true
        profileEmailLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func configureSettingsCells() {
        settingsCells = [
            SettingsMenu(icon: UIImage(systemName: "gearshape")!, title: "Settings", handler: {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SettingsControllerP"), object: nil)
            }),
            SettingsMenu(icon: UIImage(systemName: "car")!, title: "Your Trips", handler: {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "YourTripsControllerP"), object: nil)
            }),
            SettingsMenu(icon: UIImage(systemName: "person.crop.circle.badge.xmark.fill")!, title: "Log out", handler: {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SignoutP"), object: nil)
            })
        ]
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
    }

}

extension SideMenuDViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SideMenuTableViewCell
        let setting = settingsCells[indexPath.row]
        cell.iconImageView.image = setting.icon
        cell.nameLabel.text = setting.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

