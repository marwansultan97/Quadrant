//
//  LocationInputController.swift
//  Uber
//
//  Created by Marwan Osama on 11/29/20.
//

import UIKit
import Hero
import MapKit
import Firebase
import Combine

protocol LocationInputControllerDelegate: class {
    func deliverPlaceDetails(place: MKPlacemark)
}

class LocationInputController: UIViewController {
    
    var userFullName: String?
    
    var homePlace: MKPlacemark? {
        didSet {
            guard homePlace != nil else {return}
            self.tableView.reloadData()
        }
    }
    
    var workPlace: MKPlacemark? {
        didSet {
            guard workPlace != nil else {return}
            self.tableView.reloadData()
        }
    }
    
    var delegate: LocationInputControllerDelegate?
    var places: [MKPlacemark]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var viewModel = LocationInputViewModel()
    var subscribtion = Set<AnyCancellable>()
    
    
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
        setSubscribtion()
        configureUI()
        configureTableView()
        configureTF()
    }
    
    
    //MARK: - UI methods
    func configureTF() {
        destinationLocationTF.delegate = self
        destinationLocationTF.becomeFirstResponder()
    }
    
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.heroNavigationAnimationType = .fade
        locationInputView.hero.modifiers = [.arc]
        fullnameLabel.text = userFullName
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.hero.isEnabled = true
    }
    
    
    func setSubscribtion() {
        subscribtion = [
            
            viewModel.$homePlace.assign(to: \.homePlace, on: self),
            viewModel.$workPlace.assign(to: \.workPlace, on: self)
            
        ]
    }

    
    //MARK: - Button Actions
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - TableView Methods
extension LocationInputController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 18))
        headerView.backgroundColor = .label
        headerView.alpha = 0.7
        let label = UILabel(frame: CGRect(x: 10, y: 2, width: self.tableView.frame.width, height: 19))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .systemBackground
        label.text = section == 0 ? "Favorite Places".localize : "Search Results".localize
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 90 : 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoritePlacesLocationInputTableViewCell.identifier, for: indexPath) as! FavoritePlacesLocationInputTableViewCell
            if indexPath.row == 0 {
                let image = UIImage(systemName: "house")
                cell.configureCell(place: self.homePlace, image: image!, placeType: "Home")
                return cell
            } else {
                let image = UIImage(systemName: "laptopcomputer.and.iphone")
                cell.configureCell(place: self.workPlace, image: image!, placeType: "Work")
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
            guard let placeMark = self.places?[indexPath.row] else { return cell }
            cell.configureCell(place: placeMark)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                guard homePlace != nil else {return}
                navigationController?.popViewController(animated: true)
                delegate?.deliverPlaceDetails(place: homePlace!)
            } else if indexPath.row == 1 {
                guard workPlace != nil else {return}
                navigationController?.popViewController(animated: true)
                delegate?.deliverPlaceDetails(place: workPlace!)
            }
        } else if indexPath.section == 1 {
            guard let placeMark = self.places?[indexPath.row] else {return}
            navigationController?.popViewController(animated: true)
            delegate?.deliverPlaceDetails(place: placeMark)
        }
    }
    
    
}

//MARK: - Text Field Delegate
extension LocationInputController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        MapLocationServices.shared.seachPlacesOnMap(query: query) { (places, err) in
            if err != nil {
                print("DEBUG: error searching places \(err!.localizedDescription)")
            } else {
                self.places = places
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
