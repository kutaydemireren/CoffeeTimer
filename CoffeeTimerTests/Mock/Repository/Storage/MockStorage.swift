//
//  MockStorage.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 30/05/2023.
//

@testable import CoffeeTimer

final class MockStorage: Storage {
    var storageDictionary: [String: Any] = [:]
    
    var saveCalledWithKey: String?
    var saveCalledWithValue: Any?
    var saveCalledCount = 0
    var saveCalls: [(key: String, value: Any?)] = []
    
    var loadCalledCount = 0
    var loadCalledWithKey: String?
    var loadCalls: [String] = []
    
    func save<T>(_ value: T?, forKey key: String) {
        saveCalledCount += 1
        saveCalledWithKey = key
        saveCalledWithValue = value
        saveCalls.append((key, value))
        storageDictionary[key] = value
    }
    
    func load<T>(forKey key: String) -> T? {
        loadCalledCount += 1
        loadCalledWithKey = key
        loadCalls.append(key)
        return storageDictionary[key] as? T
    }
}
