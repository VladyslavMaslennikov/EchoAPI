//
//  URLBuilder.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import UIKit

class URLBuilder {
    private var type: RequestType
    private var components: URLComponents?
    private var urlRequest: URLRequest?
    init(type: RequestType) {
        self.type = type
        self.components = generateUrlComponents()
        self.urlRequest = generateURLRequest()
    }
    
    private func generateUrlComponents() -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "apiecho.cf"
        switch type {
        case .signup:
            urlComponents.path = "/api/signup/"
        case .login:
            urlComponents.path = "/api/login/"
        case .logout:
            urlComponents.path = "/api/logout/"
        case .fetchText(_, let locale):
            urlComponents.path = "/api/get/text/"
            let queryParameters = [
                "locale": locale,
            ]
            let queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlComponents.queryItems = queryItems
        }
        return urlComponents
    }
    
    private func generateURLRequest() -> URLRequest? {
        guard let components = self.components,
              let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        switch self.type {
        case .signup(let name, let email, let password):
            request.httpMethod = "POST"
            let signupBody = SignupBody(name: name, email: email, password: password)
            let httpBody = Converter.encode(signupBody)
            request.httpBody = httpBody
        case .login(let email, let password):
            request.httpMethod = "POST"
            let loginBody = LoginBody(email: email, password: password)
            let httpBody = Converter.encode(loginBody)
            request.httpBody = httpBody
        case .logout:
            request.httpMethod = "POST"
        case .fetchText(let token, _):
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func getUrlRequest() -> URLRequest? {
        return self.urlRequest
    }
}
