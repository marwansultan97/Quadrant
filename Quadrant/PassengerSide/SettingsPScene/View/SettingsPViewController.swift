//
//  SettingsPViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/20/21.
//

import UIKit
import RxCocoa
import RxSwift

class SettingsPViewController: UIViewController {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let profileCellIdentifier = "ProfileInfosTableViewCell"
    private let favoritePlacesCellIdentifier = "FavoritePlacesTableViewCell"
    
    private let bag = DisposeBag()
    private var viewModel = SettingsPViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        bindViewModelData()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        viewModel.fetchUser()
        viewModel.fetchHomePlace()
        viewModel.fetchWorkPlace()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: profileCellIdentifier, bundle: nil), forCellReuseIdentifier: profileCellIdentifier)
        tableView.register(UINib(nibName: favoritePlacesCellIdentifier, bundle: nil), forCellReuseIdentifier: favoritePlacesCellIdentifier)
    }
    
    private func bindViewModelData() {
        
        viewModel.isLoadingBehavior
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.containerView.alpha = 0
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.containerView.alpha = 1
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.reloadData()
                }
            }).disposed(by: bag)
        
    }
    

    

}

extension SettingsPViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 30))
        headerView.backgroundColor = UIColor(rgb: 0xEB0000)
        headerView.alpha = 0.7
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: self.tableView.frame.width, height: 20))
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.text = "Favorite Places"
        headerView.addSubview(label)
        return section == 0 ? nil : headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellIdentifier, for: indexPath) as! ProfileInfosTableViewCell
            guard viewModel.userBehavior.value != nil else { return cell }
            cell.configureCell(user: viewModel.userBehavior.value!)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: favoritePlacesCellIdentifier, for: indexPath) as! FavoritePlacesTableViewCell
            cell.placeType = indexPath.row == 0 ? .home : .work
            indexPath.row == 0 ? cell.configureCell(place: viewModel.homePlaceBehavior.value) : cell.configureCell(place: viewModel.workPlaceBehavior.value)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            
            let vc = UIStoryboard(name: "EditAccountP", bundle: nil).instantiateInitialViewController() as? EditAccountPViewController
            vc?.title = "Edit Account"
            self.navigationController?.pushViewController(vc!, animated: true)
            
        } else {
            
            let vc = UIStoryboard(name: "SetupFavoritePlace", bundle: nil).instantiateInitialViewController() as? SetupFavoritePlaceViewController
            vc?.useCase = indexPath.row == 0 ? .home : .work
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100 : 70
    }
    
    
}
