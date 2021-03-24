//
//  SetupFavoritePlaceViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/20/21.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

//MARK: - UseCases
enum FavoritePlaceUseCase: String {
    case home = "Home"
    case work = "Work"
}

class SetupFavoritePlaceViewController: UIViewController {

    //MARK: - View Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentPlaceButton: UIButton!
    
    
    var useCase: FavoritePlaceUseCase?
    
    private let bag = DisposeBag()
    private var viewModel = SetupFavoritePlaceViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        bindViewModelData()
        currentLocationButtonTapped()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        configureSearchBar()
        
    }

    //MARK: - UI Configurations
    private func configureUI() {
        title = useCase!.rawValue + " Place"
        currentLocationLabel.text = "Search places or make your current location as \(useCase!.rawValue)"
        currentPlaceButton.setTitle("Current location as \(useCase!.rawValue)", for: .normal)
        currentPlaceButton.layer.cornerRadius = 10
    }
    
    //MARK: - SearchBar Configurations
    private func configureSearchBar() {
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor(rgb: 0xEB0000)
        searchBar.backgroundImage = UIImage()
        
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.viewModel.placesBehavior.accept([])
                self?.searchBar.text = ""
                self?.view.endEditing(true)
            }).disposed(by: bag)
        
        searchBar.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                if query.isEmpty {
                    self?.viewModel.placesBehavior.accept([])
                } else {
                    self?.viewModel.seachPlacesOnMap(query: query)
                }
            }).disposed(by: bag)
    }
    
    //MARK: - TableView Configurations
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    //MARK: - ViewModel Binding
    private func bindViewModelData() {
        viewModel.placesBehavior.subscribe(onNext: { [weak self] places in
            if places.isEmpty {
                self?.tableView.alpha = 0
            } else {
                self?.tableView.alpha = 1
            }
            self?.tableView.reloadData()
        }, onDisposed: {
            print("Button Disposed")
        }).disposed(by: bag)
        
        viewModel.isUpdateSuccess.subscribe(onNext: { [weak self] isUpdateSuccess in
            if isUpdateSuccess {
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: bag)
        
    }
    
    //MARK: - Buttons Configurations
    private func currentLocationButtonTapped() {
        currentPlaceButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewModel.updateCurrentLocationAsFav(placeType: self.useCase!)
        }).disposed(by: bag)
    }
        

}

//MARK: - TableView Delegates
extension SetupFavoritePlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placesBehavior.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard !viewModel.placesBehavior.value.isEmpty else { return cell }
        let place = viewModel.placesBehavior.value[indexPath.row]
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
        tableView.deselectRow(at: indexPath, animated: true)
        guard !viewModel.placesBehavior.value.isEmpty else { return }
        let place = viewModel.placesBehavior.value[indexPath.row]
        viewModel.updateFavoritePlaces(placeType: useCase!, place: place)
    }
    
    
}
