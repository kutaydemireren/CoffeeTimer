//
//  Entities+Stub.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

extension Recipe {
    static var stubSingleV60: Recipe {
        return Recipe(
            recipeProfile: .stubSingleV60,
            ingredients: .stubSingleV60,
            brewQueue: .stubSingleV60
        )
    }

    static var stubFrenchPress: Recipe {
        return Recipe(
            recipeProfile: .stubFrenchPress,
            ingredients: .stubFrenchPress,
            brewQueue: .stubFrenchPress
        )
    }
}

extension CreateRecipeInput {
    static var stubSingleV60: CreateRecipeInput{
        return CreateRecipeInput(recipeProfile: .stubSingleV60, coffee: .init(amount: 15, type: .gram), water: .init(amount: 250, type: .millilitre), ice: nil)
    }

    static var stubFrenchPress: CreateRecipeInput{
        return CreateRecipeInput(recipeProfile: .stubFrenchPress, coffee: .init(amount: 15, type: .gram), water: .init(amount: 250, type: .millilitre), ice: nil)
    }
}

extension RecipeProfile {
    static var stubSingleV60: RecipeProfile {
        return RecipeProfile(
            name: "Single V60 Recipe", 
            brewMethod: .v60Single
        )
    }

    static var stubFrenchPress: RecipeProfile {
        return RecipeProfile(
            name: "The Great French",
            brewMethod: .frenchPress()
        )
    }
}

extension Array where Element == Ingredient {
    static var stubSingleV60: [Ingredient] {
        return [
            Ingredient(ingredientType: .coffee, amount: .init(amount: 15, type: .gram)),
            Ingredient(ingredientType: .water, amount: .init(amount: 1000, type: .millilitre))
        ]
    }

    static var stubFrenchPress: [Ingredient] {
        return [
            Ingredient(ingredientType: .coffee, amount: .init(amount: 15, type: .gram)),
            Ingredient(ingredientType: .water, amount: .init(amount: 250, type: .millilitre))
        ]
    }
}

extension BrewQueue {
    static var stubSingleV60: BrewQueue {
        var context = InstructionActionContext(current: nil, total: nil)
        let stages = loadV60SingleRecipeInstructions()
            .steps
            .compactMap { $0.instructionAction?.stage(for: RecipeInstructionInput(ingredients: [.coffee: 15, .water: 250]), in: &context) }

        return BrewQueue(stages: stages)
    }

    static var stubFrenchPress: BrewQueue {
        var context = InstructionActionContext(current: nil, total: nil)
        let stages = loadV60SingleRecipeInstructions()
            .steps
            .compactMap { $0.instructionAction?.stage(for: RecipeInstructionInput(ingredients: [.coffee: 15, .water: 250]), in: &context) }

        return BrewQueue(stages: stages)
    }
}
