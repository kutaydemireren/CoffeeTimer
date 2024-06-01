//
//  FetchRecipeInstructionsUseCaseImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation

protocol FetchRecipeInstructionsUseCase {
    func fetch(brewMethod: BrewMethod) throws -> RecipeInstructions
}

struct FetchRecipeInstructionsUseCaseImp: FetchRecipeInstructionsUseCase {
    var repository: RecipeInstructionsRepository

    init(repository: RecipeInstructionsRepository = RecipeInstructionsRepositoryImp()) {
        self.repository = repository
    }

    func fetch(brewMethod: BrewMethod) throws -> RecipeInstructions {
        try repository.fetchInstructions(for: brewMethod)
    }
}
