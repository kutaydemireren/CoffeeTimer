//
//  CreateV60SingleCupRecipeUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/04/2023.
//

import Foundation

struct CreateV60SingleCupRecipeInputs {
	let recipeProfile: RecipeProfile
	let coffee: IngredientAmount
	let water: IngredientAmount
}

protocol CreateV60SingleCupRecipeUseCase {
	func create(inputs: CreateV60SingleCupRecipeInputs) -> Recipe
}

struct CreateV60SingleCupRecipeUseCaseImp: CreateV60SingleCupRecipeUseCase {

	private let stageCount: UInt = 5

	func create(inputs: CreateV60SingleCupRecipeInputs) -> Recipe {
		let stagesBloom = createBloom(inputs: inputs)
		let stagesBrew: [BrewStage] = createBrew(inputs: inputs)
		let stageFinish = [BrewStage(action: .finish, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive)]
		let stagesAll = stagesBloom + stagesBrew + stageFinish

		return Recipe(
			recipeProfile: inputs.recipeProfile,
			ingredients: [
				.init(ingredientType: .coffee, amount: inputs.coffee),
				.init(ingredientType: .water, amount: inputs.water),
			],
			brewQueue: .init(stages: stagesAll)
		)
	}

	private func createBloom(inputs: CreateV60SingleCupRecipeInputs) -> [BrewStage] {
		let waterPerBlock = IngredientAmount(amount: inputs.water.amount / stageCount, type: .gram)

		return [
			.init(action: .wet, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .put(coffee: inputs.coffee), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(5), startMethod: .userInteractive, passMethod: .auto),
			.init(action: .pause, requirement: .countdown(5), startMethod: .auto, passMethod: .auto),
			.init(action: .swirl, requirement: .countdown(5), startMethod: .userInteractive, passMethod: .auto),
			.init(action: .pause, requirement: .countdown(45), startMethod: .auto, passMethod: .auto)
		]
	}

	private func createBrew(inputs: CreateV60SingleCupRecipeInputs) -> [BrewStage] {
		let waterPerBlock = IngredientAmount(amount: inputs.water.amount / stageCount, type: .gram)

		return (1..<stageCount).flatMap { index in
			let pour = [BrewStage(action: .pour(water: waterPerBlock), requirement: .countdown(index == 1 ? 15 : 10), startMethod: .userInteractive, passMethod: .auto)]
			let pause = index == stageCount - 1 ? [] : [BrewStage(action: .pause, requirement: .countdown(10), startMethod: .auto, passMethod: .auto)]
			return pour + pause
		}
	}
}
