//
//  SideMenuController.swift
//  Uber
//
//  Created by Marwan Osama on 12/22/20.
//

struct SettingsMenu {
    let icon: UIImage
    let title: String
    let handler: (()-> Void)
}


import UIKit
import Firebase
import SideMenuSwift
import Reachability
import TTGSnackbar


class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var topViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
    
    var user: User? {
        didSet {
            fullNameLabel.text = "\(user!.firstname) \(user!.surname)"
            emailLabel.text = user!.email
            let firstChar = user?.firstname.first?.lowercased()
            profileImageView.image = UIImage(systemName: "\(firstChar!).circle")
            profileImageView.tintColor = .systemBackground
        }
    }

    
    let reachability = try! Reachability()
    
    var models = [SettingsMenu]()
    
    var snackBar: TTGSnackbar?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureReachbility()
        fetchUserData()
        configureUI()
        configureTableView()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK: - Configure Reachability and SnackBar
    func configureReachbility() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case.wifi:
            configureSettingMenu()
            guard snackBar != nil else {return}
            snackBar?.dismiss()
            snackBar = showSnackbar(message: "Connected Successfully!",
                                    backgroundColor: .systemGreen,
                                    icon: UIImage(systemName: "checkmark.circle.fill")!,
                                    duration: .middle)
            snackBar?.show()
        case.cellular:
            configureSettingMenu()
            snackBar?.dismiss()
            snackBar = showSnackbar(message: "Connected Successfully!",
                                    backgroundColor: .systemGreen,
                                    icon: UIImage(systemName: "checkmark.circle.fill")!,
                                    duration: .middle)
            snackBar?.show()
        case.unavailable:
            snackBar = showSnackbar(message: "No Internet Connection",
                                    backgroundColor: .red,
                                    icon: UIImage(systemName: "xmark.circle")!,
                                    duration: .forever)
            snackBar?.show()
            self.models = []
            self.tableView.reloadData()
        case .none:
            break
        }
    }
    
    func showSnackbar(message: String, backgroundColor: UIColor,icon: UIImage, duration: TTGSnackbarDuration) -> TTGSnackbar {
        let snackbar = TTGSnackbar(message: message, duration: duration)
        snackbar.messageTextAlign = .center
        snackbar.messageTextColor = .white
        snackbar.cornerRadius = 5
        snackbar.leftMargin = 20
        snackbar.rightMargin = 20
        snackbar.icon = icon
        snackbar.iconImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        snackbar.iconImageView.tintColor = .white
        snackbar.backgroundColor = backgroundColor
        snackbar.animationType = .slideFromBottomToTop
        snackbar.onTapBlock = { snackbar in
            snackbar.dismiss()
        }
        snackbar.onSwipeBlock = { (snackbar, direction) in
            if direction == .right {
                    snackbar.animationType = .slideFromLeftToRight
                } else if direction == .left {
                    snackbar.animationType = .slideFromRightToLeft
                } else if direction == .up {
                    snackbar.animationType = .slideFromBottomToTop
                } else if direction == .down {
                    snackbar.animationType = .slideFromTopToBottom
                }
                snackbar.dismiss()
        }
        return snackbar
    }
    
    //MARK: - UI Methods

    func configureSettingMenu() {
        self.models = [
            SettingsMenu(icon: UIImage(systemName: "gearshape")!, title: "Settings", handler: {
                self.sideMenuController?.hideMenu()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SettingsController"), object: nil)
            }),
            SettingsMenu(icon: UIImage(systemName: "car")!, title: "Your Trips", handler: {
                self.sideMenuController?.hideMenu()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "YourTripsController"), object: nil)
            }),
            SettingsMenu(icon: UIImage(systemName: "person.crop.circle.badge.xmark.fill")!, title: "Log out", handler: {
                self.sideMenuController?.hideMenu()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "signout"), object: nil)
            })
        ]
        self.tableView.reloadData()
    }
    
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
    
    
    //MARK: - API Methods
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(userID: uid) { (user) in
            self.user = user
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditAccountController" {
            let destinationVC = segue.destination as! EditAccountController
            destinationVC.user = self.user
        }
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

