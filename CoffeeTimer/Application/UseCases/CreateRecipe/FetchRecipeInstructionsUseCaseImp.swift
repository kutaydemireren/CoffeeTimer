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
    func fetch(brewMethod: BrewMethod) throws -> RecipeInstructions {
        fatalError("missing implementation")
    }
}
