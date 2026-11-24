//
//  RemoveBrewMethodUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/12/2024.
//

import Foundation

protocol RemoveBrewMethodUseCase {
    func remove(brewMethod: BrewMethod) async
    /// Puts a removed method back, for Undo. Its steps are kept on removal, so only the method is saved again.
    func restore(brewMethod: BrewMethod) async
}

final class RemoveBrewMethodUseCaseImp: RemoveBrewMethodUseCase {
    private let brewMethodRepository: BrewMethodRepository

    init(brewMethodRepository: BrewMethodRepository = BrewMethodRepositoryImp()) {
        self.brewMethodRepository = brewMethodRepository
    }

    func remove(brewMethod: BrewMethod) async {
        guard MethodDraftFactory.isOwn(brewMethod) else { return }
        try? await brewMethodRepository.remove(brewMethod: brewMethod)
    }

    func restore(brewMethod: BrewMethod) async {
        guard MethodDraftFactory.isOwn(brewMethod) else { return }
        try? await brewMethodRepository.save(brewMethod: brewMethod)
    }
}
