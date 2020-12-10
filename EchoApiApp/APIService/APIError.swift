//
//  APIError.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import UIKit

enum APIError: String, Error {
    case code418 = "General error"
    case code422 = "Validation error"
    case unknown = "Unknown error"
    case decodingFailure = "Unable to decode data"
    case emailIsAlreadyTaken = "This email address has already been taken"
    case incorrectEmailOrPass = "Incorrect Email or Password"
    case emailOrPasswordBlank = "Password cannot be blank"
    case emailNotValid = "Email is not a valid email address"
    case passwordTooSmall = "Password should contain at least 5 characters"
    case nameBlank = "Name cannot be blank"
    case emailBlank = "Email cannot be blank"
    
    public var description: String {
        return self.rawValue
    }
}
