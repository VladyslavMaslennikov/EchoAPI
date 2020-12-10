//
//  JSONCoder.swift
//  EchoApiApp
//
//  Created by Vladyslav on 09.12.2020.
//

import Foundation

struct Converter {
    static func decode<T>(data: Data) -> T? where T: Codable {
//        let json = try? JSONSerialization.jsonObject(with: data, options: [])
//        print(json)
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            print("Unable to decode data."); return nil
        }
        return decoded
    }
    
    static func encode<T: Codable>(_ codable: T) -> Data? {
        guard let encoded = try? JSONEncoder().encode(codable.self) else {
            print("Unable to encode data."); return nil
        }
        return encoded
    }
}
