//
//  ResultsController.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

class ResultsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var credentials: UserCredentials?
    private var viewModel: ResultsViewModel?

    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.fetchRequest()
    }

    //MARK: - IBActions
    @IBAction func logoutButtonPressed(_ sender: Any) {
        viewModel?.logout { [weak self] in
            self?.dismissController()
        }
    }
    @IBAction func refreshButtonPressed(_ sender: Any) {
        viewModel?.fetchRequest()
    }
    
    //MARK: - Private methods
    private func dismissController() {
        DispatchQueue.main.async {
            let defaults = UserDefaultsManager.shared
            defaults.logoutUser()
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AuthControllerNavigation")
            sceneDelegate.window?.rootViewController = vc
        }
    }
    
    private func setupController() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if let credentials = credentials {
            viewModel = ResultsViewModel(token: credentials.token)
        } else {
            dismissController()
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        viewModel?.bindTableView(tableView)
    }
}
