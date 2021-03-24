//
//  ProgressHUD.swift
//  Uber
//
//  Created by Marwan Osama on 1/5/21.
//

import SVProgressHUD
import UIKit
import JSSAlertView


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
    
    
}
