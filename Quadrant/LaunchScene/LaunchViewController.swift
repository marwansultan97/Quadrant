//
//  LaunchViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/24/21.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class LaunchViewController: UIViewController {

    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        loadingView.type = .ballPulseSync
        loadingView.color = UIColor(rgb: 0xEB0000)
        loadingView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.checkAuthenticatedUser()
        }

    }

    
    private func checkAuthenticatedUser() {
        if Auth.auth().currentUser != nil {
            fetchUserData()
        } else {
            let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            navigationController?.pushViewController(loginVC!, animated: true)
        }
    }
    
    func fetchUserData() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.loadingView.stopAnimating()
            if user.accountType == .passenger {
                let homeP = UIStoryboard(name: "HomeP", bundle: nil).instantiateInitialViewController()
                self.navigationController?.pushViewController(homeP!, animated: true)
            } else {
                let homeD = UIStoryboard(name: "HomeD", bundle: nil).instantiateInitialViewController()
                self.navigationController?.pushViewController(homeD!, animated: true)
            }
        }
    }
    

    

}
