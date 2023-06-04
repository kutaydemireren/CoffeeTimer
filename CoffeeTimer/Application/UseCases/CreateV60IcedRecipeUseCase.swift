//
//  CreateV60IcedRecipeUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/06/2023.
//

import Foundation

protocol CreateV60IcedRecipeUseCase {
	func create(input: CreateV60RecipeInput) -> Recipe
}

struct CreateV60IcedRecipeUseCaseImp: CreateV60IcedRecipeUseCase {
	func create(input: CreateV60RecipeInput) -> Recipe {
		let stagesBloom = createBloom(input: input)
		let stagesBrew: [BrewStage] = createBrew(input: input)
		let stageFinish = [BrewStage(action: .finishIced, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive)]
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
		return [
			BrewStage(action: .wet, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			BrewStage(action: .putIce(iceAmount(input: input)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			BrewStage(action: .putCoffee(input.coffee), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			BrewStage(action: .pour(water: hotWaterAmountForBloom(input: input)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			BrewStage(action: .swirl, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			BrewStage(action: .pause, requirement: .countdown(40), startMethod: .auto, passMethod: .auto),
		]
	}

	private func iceAmount(input: CreateV60RecipeInput) -> IngredientAmount {
		return IngredientAmount(amount: UInt(Double(input.water.amount) * 0.4), type: .gram)
	}

	private func hotWaterAmountForBloom(input: CreateV60RecipeInput) -> IngredientAmount {
		return IngredientAmount(amount: input.coffee.amount * 3, type: .gram)
	}

	private func createBrew(input: CreateV60RecipeInput) -> [BrewStage] {
		let remainingHotWaterAmount = hotWaterAmount(input: input).amount - hotWaterAmountForBloom(input: input).amount

		return [
			BrewStage(action: .pour(water: IngredientAmount(amount: remainingHotWaterAmount, type: .gram)), requirement: .countdown(60), startMethod: .userInteractive, passMethod: .userInteractive),
			BrewStage(action: .pause, requirement: .countdown(10), startMethod: .auto, passMethod: .auto),
			BrewStage(action: .swirlThoroughly, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive)
		]
	}

	private func hotWaterAmount(input: CreateV60RecipeInput) -> IngredientAmount {
		return IngredientAmount(amount: input.water.amount - iceAmount(input: input).amount, type: .gram)
	}
}
