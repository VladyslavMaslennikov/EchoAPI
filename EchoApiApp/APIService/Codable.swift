//
//  Codable.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import Foundation

//MARK: - HTTPBody
struct LoginBody: Codable {
    let email: String
    let password: String
}

struct SignupBody: Codable {
    let name: String
    let email: String
    let password: String
}

//MARK: - HTTPURLResponse
struct LogoutResponse: Codable {
    let success: Bool
    let data: String
}

struct FetchTextResponse: Codable {
    let success: Bool
    let data: String
}

struct RequestResponse: Codable {
    let success: Bool
    let data: User
}

struct User: Codable {
    let uid: Int
    let name: String
    let email: String
    let access_token: String
    let role: Int
    let status: Int
    let created_at: Int
    let updated_at: Int
}

//MARK: - Error status code responses
struct ErrorResponse: Codable {
    let success: Bool
    let errors: [ErrorField]
}

struct ErrorField: Codable {
    let name: String //documentation states it's is named as "field"
    let message: String
}
