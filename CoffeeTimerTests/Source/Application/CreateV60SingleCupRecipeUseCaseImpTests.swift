//
//  CreateV60SingleCupRecipeUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 02/04/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateV60SingleCupRecipeUseCaseImpTests: XCTestCase {

	let coffeeAmount = IngredientAmount(amount: 15, type: .gram)
	let waterAmount = IngredientAmount(amount: 250, type: .gram)
	let waterPerBlock = IngredientAmount(amount: 50, type: .gram)

	var sut: CreateV60SingleCupRecipeUseCaseImp!

	override func setUpWithError() throws {
		try super.setUpWithError()
		sut = CreateV60SingleCupRecipeUseCaseImp()
	}

	func test_create_shouldReturnWithExpectedRecipeProfile() {
		let resultedRecipe = sut.create(inputs: .init(recipeProfile: .init(name: name, icon: .stub), coffee: coffeeAmount, water: waterAmount))

		XCTAssertEqual(resultedRecipe.recipeProfile, expectedRecipe(name: name).recipeProfile)
	}

	func test_create_shouldReturnWithExpectedBrewQueue() {
		let resultedRecipe = sut.create(inputs: .init(recipeProfile: .init(name: name, icon: .stub), coffee: coffeeAmount, water: waterAmount))

		XCTAssertEqual(resultedRecipe.brewQueue, expectedRecipe(name: name).brewQueue)
	}

	func test_create_shouldReturnWithExpectedIngredients() {
		let resultedRecipe = sut.create(inputs: .init(recipeProfile: .init(name: name, icon: .stub), coffee: coffeeAmount, water: waterAmount))

		XCTAssertEqual(resultedRecipe.ingredients, expectedRecipe(name: name).ingredients)
	}
}

extension CreateV60SingleCupRecipeUseCaseImpTests {
	var expectedStages: [BrewStage] {
		[
			.init(action: .wet, requirement: .none),
			.init(action: .put(coffee: coffeeAmount), requirement: .none),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(5), startMethod: .auto),
			.init(action: .swirl, requirement: .countdown(5)),
			.init(action: .pause, requirement: .countdown(45), startMethod: .auto),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(15)),
			.init(action: .pause, requirement: .countdown(10), startMethod: .auto),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(10)),
			.init(action: .pause, requirement: .countdown(10), startMethod: .auto),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(10)),
			.init(action: .pause, requirement: .countdown(10), startMethod: .auto),
			.init(action: .pour(water: waterPerBlock), requirement: .countdown(10)),
			.init(action: .finish, requirement: .none)
		]
	}
	var expectedIngredients: [Ingredient] {
		[
			Ingredient(ingredientType: .coffee, amount: coffeeAmount),
			Ingredient(ingredientType: .water, amount: waterAmount)
		]
	}

	func expectedRecipe(name: String) -> Recipe {
		Recipe(recipeProfile: .init(name: name, icon: .stub), ingredients: expectedIngredients, brewQueue: .init(stages: expectedStages))
	}
}
