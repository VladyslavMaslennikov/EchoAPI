//
//  UserDefaults.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    let defaults: UserDefaults
    
    private let emailKey = "email"
    private let accessTokenKey = "token"
    private let userIsLoggedKey = "userIsLogged"
    
    private init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.defaults = userDefaults
    }
    
    private func userIsLogged() -> Bool {
        let userIsLogged = defaults.bool(forKey: userIsLoggedKey)
        if !userIsLogged {
            defaults.set(false, forKey: userIsLoggedKey)
        }
        return userIsLogged
    }
    
    //MARK: Public methods
    func loginUser() {
        defaults.set(true, forKey: userIsLoggedKey)
    }
    
    func logoutUser() {
        defaults.set(false, forKey: userIsLoggedKey)
    }
    
    func setUserCredentials(email: String, token: String) {
        let userIsLogged = defaults.bool(forKey: userIsLoggedKey)
        if !userIsLogged {
            defaults.set(true, forKey: userIsLoggedKey)
        }
        defaults.set(email, forKey: emailKey)
        defaults.set(token, forKey: accessTokenKey)
    }
 
    func getUserCredentials() -> UserCredentials? {
        let userLogged = userIsLogged()
        if userLogged {
            guard let email = defaults.string(forKey: emailKey) else { return nil }
            guard let token = defaults.string(forKey: accessTokenKey) else { return nil }
            let credentials = UserCredentials(email: email, token: token)
            return credentials
        }
        return nil
    }
    
}

struct UserCredentials {
    let email: String
    let token: String
}
