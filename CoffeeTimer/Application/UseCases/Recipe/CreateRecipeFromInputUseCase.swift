//
//  CreateRecipeFromInputUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation

protocol CreateRecipeFromInputUseCase {
    func create(from input: CreateRecipeInput, instructions: RecipeInstructions) -> Recipe
}

struct CreateRecipeFromInputUseCaseImp: CreateRecipeFromInputUseCase {
    func create(from input: CreateRecipeInput, instructions: RecipeInstructions) -> Recipe {
        return Recipe(
            recipeProfile: input.recipeProfile,
            ingredients: [
                Ingredient(ingredientType: .coffee, amount: input.coffee),
                Ingredient(ingredientType: .water, amount: input.water)
            ],
            brewQueue: getBrew(input: input, instructions: instructions)
        )
    }
    
    private func getBrew(input: CreateRecipeInput, instructions: RecipeInstructions) -> BrewQueue {
        let input = RecipeInstructionInput(
            ingredients: [
                "water": Double(input.water.amount),
                "coffee": Double(input.coffee.amount)
            ]
        )

        let stages = instructions.steps.compactMap { recipeInstructionStep in
            recipeInstructionStep.instructionAction?.stage(for: input)
        }

        return BrewQueue(stages: stages)
    }
}
