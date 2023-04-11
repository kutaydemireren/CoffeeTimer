//
//  CreateV60SingleCupRecipeUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/04/2023.
//

import Foundation

struct CreateV60SingleCupRecipeInputs {
	let name: String
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
		let stageFinish = [BrewStage(action: .finish, requirement: .none)]
		let stagesAll = stagesBloom + stagesBrew + stageFinish

		return Recipe(
			name: inputs.name,
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
			.init(action: .wet, requirement: .none),
			.init(action: .put(coffee: inputs.coffee), requirement: .none),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(5), startMethod: .auto),
			.init(action: .swirl, requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(45), startMethod: .auto)
		]
	}

	private func createBrew(inputs: CreateV60SingleCupRecipeInputs) -> [BrewStage] {
		let waterPerBlock = IngredientAmount(amount: inputs.water.amount / stageCount, type: .gram)

		return (1..<stageCount).flatMap { index in
			let pour = [BrewStage(action: .pour(water: waterPerBlock), requirement: .countdown(index == 1 ? 15 : 10))]
			let pause = index == stageCount - 1 ? [] : [BrewStage(action: .pause, requirement: .countdown(10), startMethod: .auto)]
			return pour + pause
		}
	}
}
