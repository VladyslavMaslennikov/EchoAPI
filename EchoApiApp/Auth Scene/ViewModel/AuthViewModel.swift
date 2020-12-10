//
//  AuthViewModel.swift
//  EchoApiApp
//
//  Created by Vladyslav on 08.12.2020.
//

import Foundation
import RxSwift
import RxCocoa

class AuthViewModel {
    private enum AuthType {
        case login
        case signup
    }
    
    private var credentials = AuthModel(email: "", password: "")
    private var apiService: APIService?
    
    //MARK: Rx properties
    private var username = BehaviorSubject<String>(value: "")
    private var password = BehaviorSubject<String>(value: "")
    private var authType = PublishSubject<AuthType>()
    
    private var successResponse = PublishSubject<RequestResponse>()
    private var errorMessage = PublishSubject<String>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        observeChanges()
        subscribeForAuthRequest()
    }
    
    //MARK: UI Bindings
    func bindEmailTf(_ tf: UITextField) {
        tf.rx
            .text
            .orEmpty
            .bind(to: self.username)
            .disposed(by: self.disposeBag)
    }
    
    func bindPasswordTf(_ tf: UITextField) {
        tf.rx
            .text
            .orEmpty
            .bind(to: self.password)
            .disposed(by: self.disposeBag)
    }
    
    func bindSignupButton( _ button: UIButton) {
        button.rx
            .controlEvent(.touchUpInside)
            .subscribe { [weak self] _ in
                self?.authType.onNext(.signup)
            }.disposed(by: self.disposeBag)
    }
    
    func bindLoginButton( _ button: UIButton) {
        button.rx
            .controlEvent(.touchUpInside)
            .subscribe { [weak self] _ in
                self?.authType.onNext(.login)
            }.disposed(by: self.disposeBag)
    }
    
    func subscribeForUiUpdate(in vc: UIViewController) {
        // show alert in case of error
        errorMessage
            .subscribe { message in
                guard let message = message.element else { return }
                DispatchQueue.main.async {
                    let alert = AlertManager.returnAlert(with: message)
                    vc.present(alert, animated: true, completion: nil)
                }
        }.disposed(by: self.disposeBag)
        //present results controller in case of success
        successResponse
            .subscribe { response in
                print("Authentication request successful.")
                let defaults = UserDefaultsManager.shared
                let response = response.element
                if let succeeded = response?.success, succeeded, let userData = response?.data {
                    defaults.loginUser()
                    defaults.setUserCredentials(email: userData.email, token: userData.access_token)
                    if let credentials = defaults.getUserCredentials() {
                        print("Credentials are saved to user defaults.")
                        print("Redirecting to Results Controller...")
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let resultsController = storyboard.instantiateViewController(withIdentifier: "ResultsController") as! ResultsController
                            resultsController.credentials = credentials
                            vc.navigationController?.pushViewController(resultsController, animated: true)
                        }
                    }
                }
        }.disposed(by: self.disposeBag)
    }
    
    //MARK: Private methods
    private func observeChanges() {
        _ = Observable
            .combineLatest(username, password)
            .map { (name, pass) -> AuthModel in
                return AuthModel(email: name, password: pass)
            }
            .subscribe(onNext: { [weak self] model in
                self?.credentials = model
            })
            .disposed(by: self.disposeBag)
    }
    
    private func subscribeForAuthRequest() {
        authType.subscribe { [weak self] type in
            self?.sendAuthRequest(for: type)
        }.disposed(by: self.disposeBag)
    }
    
    //MARK: Authentication Request
    private func sendAuthRequest(for type: AuthType) {
        let credentials = self.credentials
        let email = credentials.email
        let password = credentials.password
        switch type {
        case .login:
            print("Loging in...")
            apiService = APIService(requestType: .login(email: email, password: password))
            apiService?.sendAuthorizationRequest(completion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.errorMessage.onNext(error.description)
                case .success(let result):
                    self?.successResponse.onNext(result)
                }
            })
        case .signup:
            print("Signing up...")
            apiService = APIService(requestType: .signup(name: email, email: email, password: password))
            apiService?.sendAuthorizationRequest(completion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.errorMessage.onNext(error.description)
                case .success(let result):
                    self?.successResponse.onNext(result)
                }
            })
        }
    }
}
