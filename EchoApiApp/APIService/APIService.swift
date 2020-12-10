//
//  APIService.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import UIKit

enum RequestType {
    case signup(name: String, email: String, password: String)
    case login(email: String, password: String)
    case logout
    case fetchText(token: String, locale: String)
}

class APIService {
    private let type: RequestType
    private var urlBuilder: URLBuilder?
    
    init(requestType: RequestType) {
        self.type = requestType
        self.urlBuilder = URLBuilder(type: self.type)
    }
    
    func sendAuthorizationRequest(completion: @escaping (Result<RequestResponse, APIError>) -> ()) {
        let urlBuilder = URLBuilder(type: self.type)
        guard let request = urlBuilder.getUrlRequest() else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                let result: Result<RequestResponse, APIError> = self.validateResponse(response: response, data: data)
                completion(result)
            }
        }
        task.resume()
    }
    
    func fetchText(completion: @escaping (Result<FetchTextResponse, APIError>) -> ()) {
        let urlBuilder = URLBuilder(type: self.type)
        guard let request = urlBuilder.getUrlRequest() else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let response = response as? HTTPURLResponse {
                let result: Result<FetchTextResponse, APIError> = self.validateResponse(response: response, data: data)
                completion(result)
            }
        }
        task.resume()
    }
    
    func logout(completion: @escaping (Result<LogoutResponse, APIError>) -> ()) {
        let urlBuilder = URLBuilder(type: self.type)
        guard let request = urlBuilder.getUrlRequest() else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let response = response as? HTTPURLResponse {
                let result: Result<LogoutResponse, APIError> = self.validateResponse(response: response, data: data)
                completion(result)
            }
        }
        task.resume()
    }
    
    //MARK: Helper methods
    private func validateResponse<T: Codable>(response: HTTPURLResponse, data: Data?) -> Result<T, APIError> {
        let statusCode = response.statusCode
        if statusCode == 200 {
            if let data = data, let result: T = Converter.decode(data: data) {
                return .success(result)
            } else {
                return .failure(.decodingFailure)
            }
        } else if statusCode == 418 {
            return .failure(.code418)
        } else if statusCode == 422 {
            if let data = data {
                let errorResponse: ErrorResponse? = Converter.decode(data: data)
                if let errors = errorResponse?.errors, let error = errors.first?.message {
                    if error.contains(APIError.emailIsAlreadyTaken.description) {
                        return .failure(.emailIsAlreadyTaken)
                    }
                    if error.contains(APIError.emailOrPasswordBlank.description) {
                        return .failure(.emailOrPasswordBlank)
                    }
                    if error.contains(APIError.emailNotValid.description) {
                        return .failure(.emailNotValid)
                    }
                    if error.contains(APIError.passwordTooSmall.description) {
                        return .failure(.passwordTooSmall)
                    }
                    if error.contains(APIError.incorrectEmailOrPass.description) {
                        return .failure(.incorrectEmailOrPass)
                    }
                    if error.contains(APIError.nameBlank.description) {
                        return .failure(.emailBlank)
                    }
                    if error.contains(APIError.emailBlank.description) {
                        return .failure(.emailBlank)
                    }
                }
            }
            return .failure(.code422)
        } else {
            return .failure(.unknown)
        }
    }
}
