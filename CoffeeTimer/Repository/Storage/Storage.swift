//
//  Storage.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

protocol Storage {
    func save<T: Codable>(_ value: T?, forKey key: String)
    func load<T: Codable>(forKey key: String) -> T?
}

struct StorageImp: Storage {
    
    var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func save<T: Codable>(_ value: T?, forKey key: String) {
        if let value = value {
            do {
                let data = try JSONEncoder().encode(value)
                userDefaults.set(data, forKey: key)
            } catch {
                print("Error saving data for key \(key): \(error)")
            }
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
    
    func load<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let value = try JSONDecoder().decode(T.self, from: data)
            return value
        } catch {
            print("Error loading data for key \(key): \(error)")
            return nil
        }
    }
}
