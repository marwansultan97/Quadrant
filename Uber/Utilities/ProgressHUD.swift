//
//  ProgressHUD.swift
//  Uber
//
//  Created by Marwan Osama on 1/5/21.
//

import SVProgressHUD
import UIKit

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


