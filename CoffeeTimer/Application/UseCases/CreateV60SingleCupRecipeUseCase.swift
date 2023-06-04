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
	private let stageCount: UInt = 5

	func create(input: CreateV60RecipeInput) -> Recipe {
		let stagesBloom = createBloom(input: input)
		let stagesBrew: [BrewStage] = createBrew(input: input)
		let stageFinish = [BrewStage(action: .finish, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive)]
		let stagesAll = stagesBloom + stagesBrew + stageFinish

		return Recipe(
			recipeProfile: input.recipeProfile,
			ingredients: [
				.init(ingredientType: .coffee, amount: input.coffee),
				.init(ingredientType: .water, amount: input.water),
			],
			brewQueue: .init(stages: stagesAll)
		)
	}

	private func createBloom(input: CreateV60RecipeInput) -> [BrewStage] {
		let waterPerBlock = IngredientAmount(amount: input.water.amount / stageCount, type: .gram)

		return [
			.init(action: .wet, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .putCoffee(input.coffee), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pourWater(waterPerBlock), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .swirl, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pause, requirement: .countdown(40), startMethod: .auto, passMethod: .auto)
		]
	}

	private func createBrew(input: CreateV60RecipeInput) -> [BrewStage] {
		let waterPerBlock = IngredientAmount(amount: input.water.amount / stageCount, type: .gram)

		return (1..<stageCount).flatMap { index in
			let pour = [BrewStage(action: .pourWater(waterPerBlock), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive)]
			let pause = index == stageCount - 1 ? [] : [BrewStage(action: .pause, requirement: .countdown(10), startMethod: .auto, passMethod: .auto)]
			return pour + pause
		}
	}
}
