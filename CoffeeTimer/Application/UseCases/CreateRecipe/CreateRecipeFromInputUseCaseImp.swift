//
//  CreateRecipeFromInputUseCaseImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation

protocol CreateRecipeFromInputUseCase {
    func create(from context: CreateV60RecipeInput, instructions: RecipeInstructions) -> Recipe
}

struct CreateRecipeFromInputUseCaseImp: CreateRecipeFromInputUseCase {
    func create(from context: CreateV60RecipeInput, instructions: RecipeInstructions) -> Recipe {
        fatalError("missing implementation")
    }
}
