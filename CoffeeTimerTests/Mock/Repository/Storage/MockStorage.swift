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

	var loadCalledWithKey: String?

	func save<T>(_ value: T?, forKey key: String) {
		saveCalledWithKey = key
		saveCalledWithValue = value
		storageDictionary[key] = value
	}

	func load<T>(forKey key: String) -> T? {
		loadCalledWithKey = key
		return storageDictionary[key] as? T
	}
}
