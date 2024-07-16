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

        let coffeeAmount = Double(input.coffee.amount)
        var waterAmount = Double(input.water.amount)
        var iceAmount = 0.0

        if instructions.ingredients.contains(.ice) {
            iceAmount = waterAmount * 0.4
            waterAmount -= iceAmount
        }

        var context = InstructionActionContext(
            totalCoffee: coffeeAmount,
            totalWater: waterAmount
        )
        let input = RecipeInstructionInput(
            ingredients: [
                "coffee": coffeeAmount,
                "water": waterAmount,
                "ice": iceAmount
            ]
        )

        let stages = instructions.steps.compactMap { recipeInstructionStep -> BrewStage? in
            return recipeInstructionStep.instructionAction?.stage(for: input, in: &context)
        }

        return BrewQueue(stages: stages)
    }
}
