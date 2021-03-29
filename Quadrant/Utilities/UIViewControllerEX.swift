//
//  ProgressHUD.swift
//  Uber
//
//  Created by Marwan Osama on 1/5/21.
//

import SVProgressHUD
import UIKit
import JSSAlertView
import TTGSnackbar


extension UIViewController {
    
    func showHUD(message: String?) {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.lightGray)
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0xEB0000))
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.show(withStatus: message)
    }
    
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
    
    func showSuccess(message: String?, dismissDelay: TimeInterval) {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.lightGray)
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0xEB0000))
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setMaximumDismissTimeInterval(dismissDelay)
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    func showError(message: String, dismissDelay: TimeInterval) {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.lightGray)
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0xEB0000))
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setMaximumDismissTimeInterval(dismissDelay)
        SVProgressHUD.showError(withStatus: message)
    }
    
    func removePreviousVCInNavigationStack() {
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers
        guard navigationArray.count > 1 else { return }
        navigationArray.remove(at: navigationArray.count - 2)
        self.navigationController?.viewControllers = navigationArray
    }
    
    func removeAllPreviousVCInNavigationStack() {
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers
        let temp = navigationArray.last
        navigationArray.removeAll()
        navigationArray.append(temp!)
        self.navigationController?.viewControllers = navigationArray
    }
    
    
    func createTTGSnackBar(message: String, icon: UIImage, color: UIColor, duration: TTGSnackbarDuration) -> TTGSnackbar {
        let connectedSnackBar = TTGSnackbar()
        connectedSnackBar.backgroundColor = color
        connectedSnackBar.messageLabel.text = message
        connectedSnackBar.messageTextFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        connectedSnackBar.messageTextAlign = .center
        connectedSnackBar.icon = icon
        connectedSnackBar.duration = duration
        connectedSnackBar.animationType = .slideFromBottomToTop
        connectedSnackBar.leftMargin = 20
        connectedSnackBar.rightMargin = 20
        connectedSnackBar.bottomMargin = 20
        connectedSnackBar.cornerRadius = 10
        
        connectedSnackBar.onTapBlock = { _ in
            connectedSnackBar.dismiss()
        }
        
        connectedSnackBar.onSwipeBlock = { (snackbar, direction) in
            if direction == .right {
                connectedSnackBar.animationType = .slideFromLeftToRight
            } else if direction == .left {
                connectedSnackBar.animationType = .slideFromRightToLeft
            } else if direction == .up {
                connectedSnackBar.animationType = .slideFromTopBackToTop
            } else if direction == .down {
                connectedSnackBar.animationType = .slideFromTopBackToTop
            }

            connectedSnackBar.dismiss()
        }
        return connectedSnackBar
    }
    
        
}
