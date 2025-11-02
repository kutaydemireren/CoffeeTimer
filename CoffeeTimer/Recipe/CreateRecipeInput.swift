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
    let id: UUID?
    
    init(
        recipeProfile: RecipeProfile,
        coffee: IngredientAmount,
        water: IngredientAmount,
        ice: IngredientAmount?,
        cupsCount: Double,
        cupSize: Double,
        id: UUID? = nil
    ) {
        self.recipeProfile = recipeProfile
        self.coffee = coffee
        self.water = water
        self.ice = ice
        self.cupsCount = cupsCount
        self.cupSize = cupSize
        self.id = id
    }
}
