//
//  YourTripsController.swift
//  Uber
//
//  Created by Marwan Osama on 12/27/20.
//

import UIKit
import MapKit
import Combine

class YourTripsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = YourTripsViewModel()
    var subscribtion = Set<AnyCancellable>()
    
    var user: User?
    
    var trips = [Trip]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setSubscribtion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    func setSubscribtion() {
        subscribtion = [
            viewModel.$trips.assign(to: \.trips, on: self)
        ]
    }
    
    //MARK: - Configure UI methods
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 180
        tableView.separatorColor = .label
        tableView.tableFooterView = UIView()
    }
        
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YourTripsTableViewCell.identifier, for: indexPath) as! YourTripsTableViewCell
        guard self.trips.count != 0 else {return cell}
        let trip = self.trips[indexPath.row]
        cell.configureCell(trip: trip, user: self.user!)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
