//
//  LocationInputViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/14/21.
//

import UIKit
import RxCocoa
import RxSwift
import MapKit

class LocationInputViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var destinationTF: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let locationCellIdentifier = "LocationInputTableViewCell"
    private let favoritePlacesCellIdentifier = "FavoritePlacesTableViewCell"
    
    private let bag = DisposeBag()
    private var viewModel = LocationInputPViewModel()
    
    var selectedPlaceMarkBehavior = BehaviorRelay<MKPlacemark?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
        configureTableView()
        bindViewModelData()
        viewModel.fetchHomePlace()
        viewModel.fetchWorkPlace()
        backButtonTapped()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func backButtonTapped() {
        backButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }, onDisposed: {
            print("Disposed")
        }).disposed(by: bag)
    }
    
    
    private func configureTextField() {
        destinationTF.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .filter({ !$0.isEmpty })
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                self?.viewModel.seachPlacesOnMap(query: query)
            }).disposed(by: bag)
    }
    
    private func bindViewModelData() {
        viewModel.placesBehavior.subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: bag)
        
        viewModel.homePlaceBehavior
            .observe(on: MainScheduler.instance)
            .filter({ $0 != nil })
            .subscribe(onNext: { [weak self] place in
                self?.tableView.reloadData()
            }).disposed(by: bag)
        
        viewModel.workPlaceBehavior
            .observe(on: MainScheduler.instance)
            .filter({ $0 != nil })
            .subscribe(onNext: { [weak self] place in
                self?.tableView.reloadData()
            }).disposed(by: bag)
        
        viewModel.isLoadingBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.tableView.alpha = 0
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.tableView.alpha = 1
                    self?.activityIndicator.stopAnimating()
                }
            }).disposed(by: bag)
        
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: locationCellIdentifier, bundle: nil), forCellReuseIdentifier: locationCellIdentifier)
        tableView.register(UINib(nibName: favoritePlacesCellIdentifier, bundle: nil), forCellReuseIdentifier: favoritePlacesCellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.keyboardDismissMode = .onDrag
    }

}

//MARK: - TabeView Delegate
extension LocationInputViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 18))
        headerView.backgroundColor = UIColor(hexString: "C90000")
        headerView.alpha = 0.7
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: self.tableView.frame.width, height: 19))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .white
        label.text = section == 0 ? "Favorite Places" : "Search Results"
        headerView.addSubview(label)
        return headerView
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : viewModel.placesBehavior.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: favoritePlacesCellIdentifier, for: indexPath) as! FavoritePlacesTableViewCell
            cell.placeType = indexPath.row == 0 ? .home : .work
            indexPath.row == 0 ? cell.configureCell(place: viewModel.homePlaceBehavior.value) : cell.configureCell(place: viewModel.workPlaceBehavior.value)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath) as! LocationInputTableViewCell
            let place = viewModel.placesBehavior.value[indexPath.row]
            cell.configureCell(place: place)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                guard viewModel.homePlaceBehavior.value != nil else { return }
                selectedPlaceMarkBehavior.accept(viewModel.homePlaceBehavior.value)
                self.dismiss(animated: true)
            } else {
                guard viewModel.workPlaceBehavior.value != nil else { return }
                selectedPlaceMarkBehavior.accept(viewModel.workPlaceBehavior.value)
                self.dismiss(animated: true)
            }

        } else {
            let selectedPlaceMark = viewModel.placesBehavior.value[indexPath.row]
            selectedPlaceMarkBehavior.accept(selectedPlaceMark)
            self.dismiss(animated: true)
        }
    }
    
    
}
