//
//  LocationInputController.swift
//  Uber
//
//  Created by Marwan Osama on 11/29/20.
//

import UIKit
import Hero
import MapKit

protocol ShowPlaceDetails: class {
    func showAnnotation(place: MKPlacemark)
}

class LocationInputController: UIViewController {
    
    var userFullName: String?
    var delegate: ShowPlaceDetails?
    var places: [MKPlacemark]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
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
        configureUI()
        configureTableView()
        destinationLocationTF.delegate = self
        
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.heroNavigationAnimationType = .fade
        locationInputView.hero.modifiers = [.arc]
        fullnameLabel.text = userFullName
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
        tableView.keyboardDismissMode = .onDrag
        tableView.hero.isEnabled = true
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
        return section == 0 ? 2 : places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        if indexPath.section == 1 {
            guard let placeMark = self.places?[indexPath.row] else {return cell}
            cell.configureCell(place: placeMark)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            print(indexPath.row)
            guard let placeMark = self.places?[indexPath.row] else {return}
            delegate?.showAnnotation(place: placeMark)
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}

//MARK: - Text Field Delegate
extension LocationInputController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        LocationHandler.shared.seachPlacesOnMap(query: query) { (places, err) in
            if err != nil {
                print("DEBUG: error searching places \(err?.localizedDescription)")
            } else {
                self.places = places
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
