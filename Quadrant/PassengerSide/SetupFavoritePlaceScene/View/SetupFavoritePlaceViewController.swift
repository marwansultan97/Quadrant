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


enum FavoritePlaceUseCase: String {
    case home = "Home"
    case work = "Work"
}

class SetupFavoritePlaceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentPlaceButton: UIButton!
    
    
    var useCase: FavoritePlaceUseCase?
    
    private let bag = DisposeBag()
    private var viewModel = SetupFavoritePlaceViewModel()
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
        bindViewModelData()
        currentLocationButtonTapped()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        configureSearchController()
    }
    
    private func configureUI() {
        title = useCase!.rawValue + " Place"
        currentLocationLabel.text = "Search places or make your current location as \(useCase!.rawValue)"
        currentPlaceButton.setTitle("Current location as \(useCase!.rawValue)", for: .normal)
        currentPlaceButton.layer.cornerRadius = 10
    }
    
    private func configureSearchController() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor(hexString: "C90000")
        

        searchController.searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            }).disposed(by: bag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.viewModel.placesBehavior.accept([])
            }).disposed(by: bag)
        
        searchController.searchBar.rx.text.orEmpty
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
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
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
    
    private func currentLocationButtonTapped() {
        currentPlaceButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.viewModel.updateCurrentLocationAsFav(placeType: self.useCase!)
        }).disposed(by: bag)
    }
        

}

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
