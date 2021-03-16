//
//  MenuViewModel.swift
//  Uber
//
//  Created by Marwan Osama on 1/8/21.
//


import UIKit
import Combine
import Firebase
import Reachability
import TTGSnackbar

// done
struct SettingsMenu {
    let icon: UIImage
    let title: String
    let handler: (()-> Void)
}

class MenuViewModel {
    
    let services = Service.shared
    let reachability = try! Reachability()
    var snackBar: TTGSnackbar?
    let uid = Auth.auth().currentUser?.uid ?? ""
    
    @Published var user: User?
    @Published var models = [SettingsMenu]()
    
    init() {
        fetchMyData()
        configureReachbility()
    }
    
    
    
    func fetchMyData() {
        services.fetchUserData(userID: uid) { (user) in
            self.user = user
        }
    }
    
    func configureSettingMenu() {
        self.models = [
            SettingsMenu(icon: UIImage(systemName: "gearshape")!, title: "Settings".localize, handler: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SettingsController"), object: nil)
            }),
            SettingsMenu(icon: UIImage(systemName: "car")!, title: "Your Trips".localize, handler: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "YourTripsController"), object: nil)
            }),
            SettingsMenu(icon: UIImage(systemName: "person.crop.circle.badge.xmark.fill")!, title: "Log out".localize, handler: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "signout"), object: nil)
            })
        ]
    }
    
    
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
            snackBar = showSnackbar(message: "Connected Successfully!".localize,
                                    backgroundColor: .systemGreen,
                                    icon: UIImage(systemName: "checkmark.circle.fill")!,
                                    duration: .middle)
            snackBar?.show()
        case.cellular:
            configureSettingMenu()
            guard snackBar != nil else {return}
            snackBar?.dismiss()
            snackBar = showSnackbar(message: "Connected Successfully!".localize,
                                    backgroundColor: .systemGreen,
                                    icon: UIImage(systemName: "checkmark.circle.fill")!,
                                    duration: .middle)
            snackBar?.show()
        case.unavailable:
            snackBar = showSnackbar(message: "No Internet Connection".localize,
                                    backgroundColor: .red,
                                    icon: UIImage(systemName: "xmark.circle")!,
                                    duration: .forever)
            snackBar?.show()
            self.models = []
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
    
    
    
    
    
    
    
    
    
}
