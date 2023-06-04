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
	let iceAmount = IngredientAmount(amount: UInt(Double(250) * 0.4), type: .gram)
	let hotWaterAmount = IngredientAmount(amount: 250 - UInt(Double(250) * 0.4), type: .gram)

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
	var input: CreateV60RecipeInput {
		return CreateV60RecipeInput(
			recipeProfile: RecipeProfile(name: name, icon: .stubSingleV60),
			coffee: coffeeAmount,
			water: waterAmount
		)
	}
	var expectedStages: [BrewStage] {
		let bloomAmount = coffeeAmount.amount * 3
		let remainingHotWaterAmount = hotWaterAmount.amount - bloomAmount

		return [
			.init(action: .wet, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .putIce(iceAmount), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .putCoffee(coffeeAmount), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pour(water: IngredientAmount(amount: bloomAmount, type: .gram)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .swirl, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pause, requirement: .countdown(40), startMethod: .auto, passMethod: .auto),
			// TODO: Differentiate remainingHotWaterAmount requirement countdown duration: remaining hot water < 200 gr of water : 60 sec : 120 sec
			.init(action: .pour(water: IngredientAmount(amount: remainingHotWaterAmount, type: .gram)), requirement: .countdown(60), startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pause, requirement: .countdown(10), startMethod: .auto, passMethod: .auto),
			.init(action: .swirlThoroughly, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .finishIced, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
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
