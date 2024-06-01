//
//  FetchRecipeInstructionsUseCaseImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation

// TODO: move

protocol RecipeInstructionsRepository {
    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions
}

//

struct RecipeInstructionsRepositoryImp: RecipeInstructionsRepository {
    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions {
        fatalError("missing implementation")
    }
}

//

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
