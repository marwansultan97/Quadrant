//
//  LoadingButton.swift
//  Uber
//
//  Created by Marwan Osama on 12/31/20.
//

import UIKit
import NVActivityIndicatorView


class LoadingButton: UIButton {
    
    var originalButtonText: String?
    var activityIndicator: NVActivityIndicatorView!
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        self.setTitle(originalButtonText, for: UIControl.State.normal)
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> NVActivityIndicatorView {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballScaleRippleMultiple, color: .label, padding: nil)
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = false
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
        
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
        
    }
    
}
