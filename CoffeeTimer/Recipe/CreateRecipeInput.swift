//
//  CreateRecipeInput.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/06/2023.
//

import Foundation

struct CreateRecipeInput {
    let recipeProfile: RecipeProfile
    let coffee: IngredientAmount
    let water: IngredientAmount
    let ice: IngredientAmount?
    let cupsCount: Double
    let cupSize: Double
}
