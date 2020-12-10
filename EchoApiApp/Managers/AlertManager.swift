//
//  AlertManager.swift
//  EchoApiApp
//
//  Created by Vladyslav on 10.12.2020.
//

import UIKit

class AlertManager {
    static func returnAlert(with text: String) -> UIAlertController {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }
}
