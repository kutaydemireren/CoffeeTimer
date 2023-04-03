//
//  CreateV60SingleCupRecipeUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 02/04/2023.
//

import XCTest
@testable import CoffeeTimer

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
