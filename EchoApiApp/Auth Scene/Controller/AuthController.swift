//
//  AuthController.swift
//  EchoApiApp
//
//  Created by Vladyslav on 08.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

class AuthController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    //MARK: - Dependencies
    private let viewModel = AuthViewModel()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setupController()
        
        viewModel.bindEmailTf(emailTf)
        viewModel.bindPasswordTf(passwordTf)
        viewModel.bindSignupButton(signupButton)
        viewModel.bindLoginButton(loginButton)
        viewModel.subscribeForUiUpdate(in: self)
    }
}

    //MARK: - UITextField Delegate
extension AuthController: UITextFieldDelegate {
    private func setDelegates() {
        emailTf.delegate = self
        passwordTf.delegate = self
    }
    
    private func setupController() {
        signupButton.layer.borderColor = UIColor.systemBlue.cgColor
        navigationController?.navigationBar.isHidden = true
        addGesture()
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap( _: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

