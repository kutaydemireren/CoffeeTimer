//
//  RemoveBrewMethodUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/12/2024.
//

import Foundation

protocol RemoveBrewMethodUseCase {
    func remove(brewMethod: BrewMethod) async throws
}

final class RemoveBrewMethodUseCaseImp: RemoveBrewMethodUseCase {
    private let brewMethodRepository: BrewMethodRepository

    init(brewMethodRepository: BrewMethodRepository = BrewMethodRepositoryImp()) {
        self.brewMethodRepository = brewMethodRepository
    }

    func remove(brewMethod: BrewMethod) async throws {
        try await brewMethodRepository.remove(brewMethod: brewMethod)
    }
}
