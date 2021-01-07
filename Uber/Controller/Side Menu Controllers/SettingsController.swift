//
//  SettingsController.swift
//  Uber
//
//  Created by Marwan Osama on 12/24/20.
//

import UIKit
import Firebase
import MapKit


class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: User?
    var kindOfPlace: String?
    var homePlace: MKPlacemark?
    var workPlace: MKPlacemark?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        fetchHomePlace()
        fetchWorkPlace()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true

    }
    
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.addSubview(UISearchBar())
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - API Methods
    func fetchHomePlace() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchHomePlace(uid: uid) { (home) in

            let homePlaceMark = Service.shared.convertFavoritePlaceToPlaceMark(place: home)
            self.homePlace = homePlaceMark
            self.tableView.reloadData()
        }
    }
    
    func fetchWorkPlace() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchWorkPlace(uid: uid) { (work) in

            let workPlaceMark = Service.shared.convertFavoritePlaceToPlaceMark(place: work)
            self.workPlace = workPlaceMark
            self.tableView.reloadData()
        }
    }
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40))
        headerView.backgroundColor = .label
        headerView.alpha = 0.7
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 2, width: 150, height: 20))
        headerLabel.textColor = .systemBackground
        headerLabel.font = UIFont.boldSystemFont(ofSize: 17)
        headerLabel.text = "Favorite Places"
        headerView.addSubview(headerLabel)
        return section == 0 ? nil : headerView

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.user?.accountType == .passenger else {return 0}
        return section == 0 ? 0 : 25
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.user?.accountType == .passenger else {return section == 0 ? 1 : 0}
        return section == 0 ? 1 : 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
            cell.configureCell(user: user!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoritePlacesSettingsTableViewCell.identifier, for: indexPath) as! FavoritePlacesSettingsTableViewCell
            if indexPath.row == 0 {
                let image = UIImage(systemName: "house")
                cell.configureCell(place: self.homePlace, image: image!, placeType: "Home")
                return cell
            } else {
                let image = UIImage(systemName: "laptopcomputer.and.iphone")
                cell.configureCell(place: self.workPlace, image: image!, placeType: "Work")
                return cell
            }
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 90 : 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "EditAccountController", sender: self)
        } else {
            if indexPath.row == 0 {
                self.kindOfPlace = "Home"
                performSegue(withIdentifier: "SearchFavoritePlacesController", sender: self)
            } else {
                self.kindOfPlace = "Work"
                performSegue(withIdentifier: "SearchFavoritePlacesController", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchFavoritePlacesController" {
            navigationItem.backButtonTitle = ""
            let destinationVC = segue.destination as! SearchFavoritePlacesController
            destinationVC.delegate = self
            destinationVC.kindOfPlace = self.kindOfPlace
        }
    }
    
}

//MARK: - FavoritePlaces Results Delegate
extension SettingsController: SearchFavoritePlacesControllerDelegate {
    
    func showSelectedPlace(kindOfPlace: String, place: MKPlacemark) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Service.shared.updateFavoritePlaces(uid: uid, placeType: kindOfPlace, place: place) { (err, ref) in
            guard err == nil else {
                print("DEBUG: Error Uploading Favorite Place \(err)")
                return
            }
            if kindOfPlace == "Home" {
                self.homePlace = place
                self.tableView.reloadData()
            } else {
                self.workPlace = place
                self.tableView.reloadData()
            }
        }
    }

    
    
}
