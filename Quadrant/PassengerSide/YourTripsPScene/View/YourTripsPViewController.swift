//
//  YouTripsPViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/19/21.
//

import UIKit
import RxCocoa
import RxSwift

class YourTripsPViewController: UIViewController {

    
    @IBOutlet weak var noTripsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "TripsTableViewCell"
    
    private let bag = DisposeBag()
    private var viewModel = YourTripsPViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchCompletedTrips()
        configureTableView()
        bindViewModelData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 170
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    private func bindViewModelData() {
        
        viewModel.tripsBehavior.subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: bag)
        
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            if isLoading {
                self?.containerView.alpha = 0
                self?.activityIndicator.startAnimating()
            } else {
                self?.containerView.alpha = 1
                self?.activityIndicator.stopAnimating()
            }
        }).disposed(by: bag)
        
        
        viewModel.noTripsError.subscribe(onNext: { [weak self] text in
            self?.containerView.alpha = 0
            self?.activityIndicator.stopAnimating()
            self?.noTripsLabel.text = text
        }).disposed(by: bag)
        
    }
    

}


extension YourTripsPViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tripsBehavior.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TripsTableViewCell
        guard !viewModel.tripsBehavior.value.isEmpty else { return cell }
        let trip = viewModel.tripsBehavior.value[indexPath.row]
        cell.cellUseCase = .passenger
        cell.configureCell(trip: trip)
        return cell
    }
    
    
}
