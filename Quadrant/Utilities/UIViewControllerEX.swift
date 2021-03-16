//
//  ProgressHUD.swift
//  Uber
//
//  Created by Marwan Osama on 1/5/21.
//

import SVProgressHUD
import UIKit
import JSSAlertView

class ProgressHUD {
    
    static let shared = ProgressHUD()
    
    func adjust() {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.label)
        SVProgressHUD.setForegroundColor(.systemBackground)
        SVProgressHUD.setDefaultAnimationType(.flat)
        
    }
    
    func show(message: String?) {
        self.adjust()
        SVProgressHUD.show(withStatus: message)
    }
    
    func dismiss() {
        self.adjust()
        SVProgressHUD.dismiss()
    }
    
    func showSuccess(message: String?) {
        self.adjust()
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    func showError(message: String) {
        self.adjust()
        SVProgressHUD.showError(withStatus: message)
    }
    
}

extension UIViewController {
    
    func showHUD(message: String?) {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.systemGray4)
        SVProgressHUD.setForegroundColor(UIColor(hexString: "C90000"))
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.show(withStatus: message)
    }
    
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
    
    func showSuccess(message: String?, dismissDelay: TimeInterval) {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.systemGray4)
        SVProgressHUD.setForegroundColor(UIColor(hexString: "C90000"))
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setMaximumDismissTimeInterval(dismissDelay)
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    func showError(message: String, dismissDelay: TimeInterval) {
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 20))
        SVProgressHUD.setBackgroundColor(.systemGray4)
        SVProgressHUD.setForegroundColor(UIColor(hexString: "C90000"))
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setMaximumDismissTimeInterval(dismissDelay)
        SVProgressHUD.showError(withStatus: message)
    }

    
}


