//
//  ResultsViewModel.swift
//  EchoApiApp
//
//  Created by Vladyslav on 10.12.2020.
//

import UIKit
import RxSwift
import RxCocoa

class ResultsViewModel {
    //MARK: Properties
    let token: String
    let locale: String
    
    private var apiService: APIService?
    private let cellId = "ResultsCell"
    //MARK: Rx properties
    private var occurences = BehaviorRelay<[String]>(value: [])
    private let disposeBag = DisposeBag()
    
    init(token: String, locale: String = "ru_RU") {
        self.token = token
        self.locale = locale
        
        apiService = APIService(requestType: .fetchText(token: self.token, locale: self.locale))
    }
    
    //MARK: - Private methods
    private func findOccurences(in text: String) -> [String] {
        let newtext = text.replacingOccurrences(of: " ", with: "")
        var dictionary: [String: Int] = [:]

        for i in newtext {
            let character = String(i)
            
            if dictionary.isEmpty {
                dictionary[character] = 1
                continue
            }
            
            var characterFound = false
            for (key, value) in dictionary {
                if characterFound {
                    break
                }
                
                if key == character {
                    dictionary[key] = value + 1
                    characterFound = true
                }
            }
            
            if !characterFound {
                dictionary[character] = 1
            }
        }

        var occurences: [String] = [text]
        for (key, value) in dictionary {
            let row = "\(key): \(value)\n"
            occurences.append(row)
        }
        print(occurences)
        return occurences
    }
    
    //MARK: - Public methods
    func fetchRequest() {
        guard let service = self.apiService else { return }
        service.fetchText { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.description)
            case .success(let result):
                if result.success {
                    DispatchQueue.global(qos: .background).async {
                        let text = result.data
                        guard let filteredText = self?.findOccurences(in: text) else { return }
                        self?.occurences.accept(filteredText)
                    }
                }
            }
        }
    }
    
    func logout(completion: @escaping () -> ()) {
        apiService = APIService(requestType: .logout)
        apiService?.logout(completion: { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                completion()
            }
        })
    }
    
    func bindTableView(_ tableView: UITableView) {
        occurences
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: ResultsCell.self)) {  row, element, cell in
                cell.titleLabel.text = element
            }.disposed(by: disposeBag)
    }
}
