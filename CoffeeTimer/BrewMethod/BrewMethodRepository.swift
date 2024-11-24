//
//  BrewMethodRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

protocol BrewMethodRepository {
    func create(brewMethod: BrewMethod) async throws
    func fetchBrewMethods() async throws -> [BrewMethod]
}
