//
//  CreateV60SingleCupRecipeUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/04/2023.
//

import Foundation

protocol CreateV60SingleCupRecipeUseCase {
	func create(input: CreateV60RecipeInput) -> Recipe
}

struct CreateV60SingleCupRecipeUseCaseImp: CreateV60SingleCupRecipeUseCase {
	func create(input: CreateV60RecipeInput) -> Recipe {
		return Recipe(
			recipeProfile: input.recipeProfile,
			ingredients: [
				.init(ingredientType: .coffee, amount: input.coffee),
				.init(ingredientType: .water, amount: input.water),
			],
			brewQueue: getBrew(input: input)
		)
	}

	private func getBrew(input: CreateV60RecipeInput) -> BrewQueue {
		let input = RecipeInstructionInput(
			ingredients: [
				"water": Double(input.water.amount),
				"coffee": Double(input.coffee.amount)
			]
		)

		return RecipeEngine
			.recipe(for: input, from: loadV60SingleRecipeInstructions())
			.brewQueue
	}
}
