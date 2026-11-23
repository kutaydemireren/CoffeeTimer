//
//  Equatable.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

extension CreateRecipeInput: @retroactive Equatable {
    public static func == (lhs: CreateRecipeInput, rhs: CreateRecipeInput) -> Bool {
        lhs.water == rhs.water &&
        lhs.coffee == rhs.coffee &&
        lhs.recipeProfile == rhs.recipeProfile
    }
}

extension CreateRecipeContext: @retroactive Equatable {
    public static func == (lhs: CreateRecipeContext, rhs: CreateRecipeContext) -> Bool {
        lhs.recipeProfile == rhs.recipeProfile
    }
}

extension RecipeInstructions: @retroactive Equatable {
    public static func == (lhs: RecipeInstructions, rhs: RecipeInstructions) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
