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
            ingredients: getIngredients(from: input),
            brewQueue: getBrew(input: input, instructions: instructions)
        )
    }

    private func getIngredients(from input: CreateRecipeInput) -> [Ingredient] {
        var ingredients = [
            Ingredient(ingredientType: .coffee, amount: input.coffee),
            Ingredient(ingredientType: .water, amount: input.water),
        ]

        if let ice = input.ice {
            ingredients.append(Ingredient(ingredientType: .ice, amount: ice))
        }

        return ingredients
    }

    private func getBrew(input: CreateRecipeInput, instructions: RecipeInstructions) -> BrewQueue {
        let coffeeAmount = Double(input.coffee.amount)
        let waterAmount = Double(input.water.amount)
        let iceAmount = Double(input.ice?.amount ?? 0)

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
