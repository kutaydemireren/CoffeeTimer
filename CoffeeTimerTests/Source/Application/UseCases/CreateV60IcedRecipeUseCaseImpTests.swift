//
//  CreateV60IcedRecipeUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 04/06/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateV60IcedRecipeUseCaseImpTests: XCTestCase {
	var coffeeAmount = IngredientAmount(amount: 17, type: .gram)
	var waterAmount = IngredientAmount(amount: 250, type: .gram)
	var iceAmount: IngredientAmount {
		IngredientAmount(amount: UInt(Double(waterAmount.amount) * 0.4), type: .gram)
	}
	var hotWaterAmount: IngredientAmount {
		IngredientAmount(amount: waterAmount.amount - iceAmount.amount, type: .gram)
	}

	var sut: CreateV60IcedRecipeUseCaseImp!

	override func setUpWithError() throws {
		sut = CreateV60IcedRecipeUseCaseImp()
	}

	func test_create_shouldReturnWithExpectedRecipeProfile() {
		let resultedRecipe = sut.create(input: input)

		XCTAssertEqual(resultedRecipe.recipeProfile, expectedRecipe(name: name).recipeProfile)
	}

	func test_create_whenRemainingHotWaterLessThan200Gr_shouldReturnWithBrewQueueWithPourWaterRequirement60Sec() {
		let resultedRecipe = sut.create(input: input)

		XCTAssertEqual(resultedRecipe.brewQueue, expectedRecipe(name: name).brewQueue)
	}

	func test_create_whenRemainingHotWaterMoreThan200Gr_shouldReturnWithBrewQueueWithPourWaterRequirement120Sec() {
		waterAmount = IngredientAmount(amount: 500, type: .gram)

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
		let pourRemainingHotWaterRequirement = BrewStageRequirement.countdown(remainingHotWaterAmount < 200 ? 60 : 120)

		return [
			.init(action: .wet, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .putIce(iceAmount), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .putCoffee(coffeeAmount), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pourWater(IngredientAmount(amount: bloomAmount, type: .gram)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .swirl, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .pause, requirement: .countdown(40), startMethod: .auto, passMethod: .auto),
			.init(action: .pourWater(IngredientAmount(amount: remainingHotWaterAmount, type: .gram)), requirement: pourRemainingHotWaterRequirement, startMethod: .userInteractive, passMethod: .userInteractive),
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
