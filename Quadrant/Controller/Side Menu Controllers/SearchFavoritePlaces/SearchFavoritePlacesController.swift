//
//  SeachFavoritePlacesController.swift
//  Uber
//
//  Created by Marwan Osama on 12/24/20.
//

import UIKit
import MapKit
import Firebase

class SearchFavoritePlacesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var places: [MKPlacemark]?
    
    var selectedPlace: MKPlacemark?
    
    var kindOfPlace: String?
    
    
    var viewModel = SearchFavoritePlacesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - UI Methods
    
    func configureSearchBar() {
        searchBar.placeholder = "Enter place name".localize
        searchBar.delegate = self
        searchBar.returnKeyType = .default
        searchBar.showsCancelButton = true
        navigationItem.titleView = searchBar
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "ERROR!".localize, message: "Please try again!".localize, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localize, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let places = self.places else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let place = places[indexPath.row]
        let name = place.name
        let thoroughFare = place.thoroughfare
        let subThoroughFare = place.subThoroughfare
        let locality = place.locality
        let adminArea = place.administrativeArea
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.text = "\(name ?? "") \(thoroughFare ?? "") \(subThoroughFare ?? "") \(locality ?? "") \(adminArea ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let places = self.places else {return}
        let place = places[indexPath.row]
        viewModel.updateFavoritePlaces(placeType: self.kindOfPlace!, place: place) { (err, ref) in
            guard err == nil else {
                self.showErrorAlert()
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    

}

//MARK: - SearchBar Delegate Methods

extension SearchFavoritePlacesController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        MapLocationServices.shared.seachPlacesOnMap(query: searchText) { (placesResponse, err) in
            self.places = placesResponse
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        self.places = nil
        self.tableView.reloadData()
    }
    
}
