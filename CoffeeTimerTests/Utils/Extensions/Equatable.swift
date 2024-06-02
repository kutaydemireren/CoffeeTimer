//
//  Equatable.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

extension CreateRecipeInput: Equatable {
    public static func == (lhs: CreateRecipeInput, rhs: CreateRecipeInput) -> Bool {
        lhs.water == rhs.water &&
        lhs.coffee == rhs.coffee &&
        lhs.recipeProfile == rhs.recipeProfile
    }
}

extension CreateRecipeContext: Equatable {
    public static func == (lhs: CreateRecipeContext, rhs: CreateRecipeContext) -> Bool {
        lhs.recipeProfile == rhs.recipeProfile
    }
}

extension RecipeInstructions: Equatable {
    public static func == (lhs: RecipeInstructions, rhs: RecipeInstructions) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
