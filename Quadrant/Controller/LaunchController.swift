//
//  LaunchScreenController.swift
//  Uber
//
//  Created by Marwan Osama on 1/1/21.
//

import UIKit
import NVActivityIndicatorView

class LaunchController: UIViewController {
    
    @IBOutlet weak var uberLabel: UILabel!
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.type = .ballTrianglePath
        indicator.color = .label
        indicator.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//            self.addAnimation()
//            self.uberLabel.text = "WELCOME!"
            self.animate()
        }
    }
    
//    func addAnimation() {
//        let animation = CATransition()
//        animation.timingFunction = CAMediaTimingFunction(name: .linear)
//        animation.duration = 0.5
//        animation.type = .fade
//        self.uberLabel.layer.add(animation, forKey: CATransitionType.fade.rawValue)
//    }
    
    func animate() {
        let welcome = "WELCOME!"
        uberLabel.text = ""
        
        for char in welcome {
            uberLabel.text! += "\(char)"
            RunLoop.current.run(until: Date()+0.15)
        }
    }
    



}
