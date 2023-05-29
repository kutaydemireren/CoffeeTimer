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
