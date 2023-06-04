//
//  CreateV60IcedRecipeUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 04/06/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateV60IcedRecipeUseCaseImpTests: XCTestCase {

	let coffeeAmount = IngredientAmount(amount: 17, type: .gram)
	let waterAmount = IngredientAmount(amount: 250, type: .gram)

	var sut: CreateV60IcedRecipeUseCaseImp!

	override func setUpWithError() throws {
		sut = CreateV60IcedRecipeUseCaseImp()
	}

	func test_create_shouldReturnWithExpectedRecipeProfile() {
		let resultedRecipe = sut.create(input: input)

		XCTAssertEqual(resultedRecipe.recipeProfile, expectedRecipe(name: name).recipeProfile)
	}

	func test_create_shouldReturnWithExpectedBrewQueue() {
		let resultedRecipe = sut.create(input: input)

		XCTAssertEqual(resultedRecipe.brewQueue, expectedRecipe(name: name).brewQueue)
	}

	func test_create_shouldReturnWithExpectedIngredients() {
		let resultedRecipe = sut.create(input: input)

		XCTAssertEqual(resultedRecipe.ingredients, expectedRecipe(name: name).ingredients)
	}
}

extension CreateV60IcedRecipeUseCaseImpTests {
	var input: CreateV60IcedRecipeInput {
		return CreateV60IcedRecipeInput(
			recipeProfile: RecipeProfile(name: name, icon: .stubSingleV60),
			coffee: coffeeAmount,
			water: waterAmount
		)
	}
	var expectedStages: [BrewStage] {
		[
		]
	}
	var expectedIngredients: [Ingredient] {
		[
			Ingredient(ingredientType: .coffee, amount: coffeeAmount),
			Ingredient(ingredientType: .water, amount: waterAmount)
		]
	}

	func expectedRecipe(name: String) -> Recipe {
		Recipe(recipeProfile: .init(name: name, icon: .stubSingleV60), ingredients: expectedIngredients, brewQueue: .init(stages: expectedStages))
	}
}
