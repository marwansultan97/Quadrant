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


struct SettingsMenu {
    let icon: UIImage
    let title: String
    let handler: (()->())
}


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
    
    override func viewDidLayoutSubviews() {
        sideMenuWidth.constant = self.view.frame.width/4 * 3
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgb: 0xF9530B).cgColor, UIColor(rgb: 0xFF9005).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = profileView.bounds
        profileView.layer.masksToBounds = true
        profileView.layer.insertSublayer(gradient, at: 0)

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
            let firstChar = user.firstname.first!.lowercased()
            self.profileImageView.image = UIImage(named: "SF_\(firstChar)_circle")
        }
    }
    

    private func configureUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderWidth = 1.5
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileNameLabel.adjustsFontSizeToFitWidth = true
        profileEmailLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func configureSettingsCells() {
        settingsCells = [
            SettingsMenu(icon: UIImage(named: "SF_gear")!, title: "Settings", handler: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SettingsD"), object: nil)
                self.sideMenuController?.hideMenu()
            }),
            SettingsMenu(icon: UIImage(named: "SF_car_fill")!, title: "Your Trips", handler: {
                self.sideMenuController?.hideMenu()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "YourTripsD"), object: nil)
                
            }),
            SettingsMenu(icon: UIImage(named: "SF_person_crop_circle_badge_plus")!, title: "Log out", handler: {
                self.sideMenuController?.hideMenu()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SignoutD"), object: nil)
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
        settingsCells[indexPath.row].handler()
    }
    
}

