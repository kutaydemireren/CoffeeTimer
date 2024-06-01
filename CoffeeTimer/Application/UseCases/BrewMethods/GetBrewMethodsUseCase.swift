//
//  GetBrewMethodsUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

// TODO: move

protocol BrewMethodRepository {
    func fetchBrewMethods() async throws -> [BrewMethod]
}

struct BrewMethodRepositoryImp: BrewMethodRepository {
    func fetchBrewMethods() async throws -> [BrewMethod] {
        fatalError("missing implementation")
    }
}

//

protocol GetBrewMethodsUseCase {
    func getAll() async throws -> [BrewMethod]
}

struct GetBrewMethodsUseCaseImp: GetBrewMethodsUseCase {
    let repository: BrewMethodRepository

    init(repository: BrewMethodRepository = BrewMethodRepositoryImp()) {
        self.repository = repository
    }

    func getAll() async throws -> [BrewMethod] {
        try await repository.fetchBrewMethods()
    }
}
