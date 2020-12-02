//
//  LocationInputController.swift
//  Uber
//
//  Created by Marwan Osama on 11/29/20.
//

import UIKit
import Hero

class LocationInputController: UIViewController {
    
    var userFullName: String?
    
    @IBOutlet weak var locationInputView: UIView!
    @IBOutlet weak var startingLocationTF: UITextField!
    @IBOutlet weak var destinationLocationTF: UITextField!
    @IBOutlet weak var linkingDot: UIView!
    @IBOutlet weak var startingDot: UIView!
    @IBOutlet weak var destinationDot: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        fullnameLabel.text = userFullName
        
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func initUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
        tableView.hero.isEnabled = true
        tableView.hero.modifiers = [.translate(x: 0, y: 30, z: 0)]
        navigationController?.navigationBar.isHidden = true
        navigationController?.heroNavigationAnimationType = .fade
        locationInputView.hero.modifiers = [.arc]
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }    
    
}


extension LocationInputController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        cell.configureCell()
        return cell
    }
    
    
}
