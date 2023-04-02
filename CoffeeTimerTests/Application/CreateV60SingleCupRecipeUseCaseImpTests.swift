//
//  CreateV60SingleCupRecipeUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 02/04/2023.
//

import XCTest
@testable import CoffeeTimer

struct CreateV60SingleCupRecipeInputs {
	let name: String
	let coffee: IngredientAmount
	let water: IngredientAmount
}

final class CreateV60SingleCupRecipeUseCaseImp {

	let stageCount: UInt = 5

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
			.init(action: .pause, requirement: .countdown(5)),
			.init(action: .swirl, requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(45))
		]
	}

	private func createBrew(inputs: CreateV60SingleCupRecipeInputs) -> [BrewStage] {
		let waterPerBlock = IngredientAmount(amount: inputs.water.amount / stageCount, type: .gram)

		return (1..<stageCount).flatMap { index in
			let pour = [BrewStage(action: .pour(water: waterPerBlock), requirement: .countdown(index == 1 ? 15 : 10))]
			let pause = index == stageCount - 1 ? [] : [BrewStage(action: .pause, requirement: .countdown(10))]
			return pour + pause
		}
	}
}

final class CreateV60SingleCupRecipeUseCaseImpTests: XCTestCase {

	var sut: CreateV60SingleCupRecipeUseCaseImp!

	override func setUpWithError() throws {
		try super.setUpWithError()
		sut = CreateV60SingleCupRecipeUseCaseImp()
	}

	func test_create_shouldCreateExpectedRecipe() {

		let coffeeAmount = IngredientAmount(amount: 15, type: .gram)
		let waterAmount = IngredientAmount(amount: 250, type: .gram)
		let waterPerBlock = IngredientAmount(amount: 50, type: .gram)
		let expectedStages: [BrewStage] = [
			.init(action: .wet, requirement: .none),
			.init(action: .put(coffee: coffeeAmount), requirement: .none),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(5)),
			.init(action: .swirl, requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(45)),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(15)),
			.init(action: .pause, requirement: .countdown(10)),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(10)),
			.init(action: .pause, requirement: .countdown(10)),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(10)),
			.init(action: .pause, requirement: .countdown(10)),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(10)),
			.init(action: .finish, requirement: .none)
		]
		let expectedName = "name"
		let expectedIngredients = [Ingredient(ingredientType: .coffee, amount: coffeeAmount), Ingredient(ingredientType: .water, amount: waterAmount)]
		let expectedRecipe = Recipe(name: expectedName, ingredients: expectedIngredients, brewQueue: .init(stages: expectedStages))

		let resultedRecipe = sut.create(inputs: .init(name: expectedName, coffee: coffeeAmount, water: waterAmount))

		XCTAssertEqual(resultedRecipe, expectedRecipe)
	}
}
