//
//  GetBrewMethodsUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

protocol GetBrewMethodsUseCase {
    func getAll() async throws -> [BrewMethod]
}

struct GetBrewMethodsUseCaseImp: GetBrewMethodsUseCase {
    func getAll() async throws -> [BrewMethod] {
        BrewMethodStorage.brewMethods
    }
}
