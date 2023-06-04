//
//  CreateV60IcedRecipeUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/06/2023.
//

import Foundation

struct CreateV60IcedRecipeInput {
	let recipeProfile: RecipeProfile
	let coffee: IngredientAmount
	let water: IngredientAmount
}

protocol CreateV60IcedRecipeUseCase {
	func create(input: CreateV60IcedRecipeInput) -> Recipe
}

struct CreateV60IcedRecipeUseCaseImp: CreateV60IcedRecipeUseCase {
	func create(input: CreateV60IcedRecipeInput) -> Recipe {
	}
}
