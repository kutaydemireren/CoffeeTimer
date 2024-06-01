//
//  BrewMethodRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

protocol BrewMethodRepository {
    func fetchBrewMethods() async throws -> [BrewMethod]
}
