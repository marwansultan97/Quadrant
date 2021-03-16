//
//  SideMenuPViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/14/21.
//

import UIKit
import ChameleonFramework

class SideMenuPViewController: UIViewController {

    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    

    private func configureUI() {
        sideMenuWidth.constant = self.view.frame.width/4 * 3
        profileView.backgroundColor = UIColor(gradientStyle: .leftToRight, withFrame: profileView.frame, andColors: [FlatOrangeDark(), FlatOrange()])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension SideMenuPViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
