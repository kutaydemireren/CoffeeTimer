//
//  FetchRecipeInstructionsUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation

// TODO: move
enum InstructionKeyword: String {
    case coffee, currentCoffee = "#current.coffee", totalCoffee = "#total.coffee", remainingCoffee = "#remaining.coffee"
    case water, currentWater = "#current.water", totalWater = "#total.water", remainingWater = "#remaining.water"
    case ice
    case currentAmount = "#current.amount"
    case currentDuration = "#current.duration"

    var keyword: String {
        return rawValue
    }
}

protocol FetchRecipeInstructionsUseCase {
    func fetch(brewMethod: BrewMethod) async throws -> RecipeInstructions
}

struct FetchRecipeInstructionsUseCaseImp: FetchRecipeInstructionsUseCase {
    var repository: RecipeInstructionsRepository

    init(repository: RecipeInstructionsRepository = RecipeInstructionsRepositoryImp()) {
        self.repository = repository
    }

    func fetch(brewMethod: BrewMethod) async throws -> RecipeInstructions {
        try await repository.fetchInstructions(for: brewMethod)
    }
}
