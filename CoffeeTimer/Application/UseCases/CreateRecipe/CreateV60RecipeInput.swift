//
//  CreateV60RecipeInput.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/06/2023.
//

import Foundation

// TODO: This could represent any `CreateRecipeInput` just as well. Remove `V60`.
struct CreateV60RecipeInput {
	let recipeProfile: RecipeProfile
	let coffee: IngredientAmount
	let water: IngredientAmount
}
