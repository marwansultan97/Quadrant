//
//  SettingsDViewController.swift
//  Quadrant
//
//  Created by Marwan Osama on 3/21/21.
//

import UIKit
import RxCocoa
import RxSwift

class SettingsDViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let profileCellIdentifier = "ProfileInfosTableViewCell"

    
    private let bag = DisposeBag()
    private var viewModel = SettingsDViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        bindViewModelData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        viewModel.fetchUser()
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

extension SettingsDViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellIdentifier, for: indexPath) as! ProfileInfosTableViewCell
        guard viewModel.userBehavior.value != nil else { return cell }
        cell.configureCell(user: viewModel.userBehavior.value!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "EditAccountP", bundle: nil).instantiateInitialViewController() as? EditAccountPViewController
        vc?.title = "Edit Account"
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
