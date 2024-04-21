//
//  RecipeInstructionsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 20/04/2024.
//

import XCTest
@testable import CoffeeTimer

final class RecipeEngineTests: XCTestCase {
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func test_recipeForInput_whenInstructionsAvailable_shouldCreateExpectedBrewQueue() throws {
		let expectedBrewQueue = BrewQueue(
			stages: [
				BrewStage(
					action: .pourWater(IngredientAmount(amount: 50, type: .gram)),
					requirement: .none,
					startMethod: .userInteractive,
					passMethod: .userInteractive
				),
				BrewStage(
					action: .pause,
					requirement: .countdown(10),
					startMethod: .auto,
					passMethod: .auto
				),
				BrewStage(
					action: .putCoffee(IngredientAmount(amount: 50, type: .gram)),
					requirement: .none,
					startMethod: .userInteractive,
					passMethod: .userInteractive
				)
			]
		)
		
		let recipe = RecipeEngine.recipe(for: .init(ingredients: ["water": 250, "coffee": 15]), from: loadTestRecipeInstructions()!)
		
		XCTAssertEqual(recipe.brewQueue, expectedBrewQueue)
	}
}

func loadTestRecipeInstructions() -> RecipeInstructions? {
	guard let bundleURL = Bundle(for: RecipeEngineTests.self).url(forResource: "test", withExtension: "json") else {
		debugPrint("Coffee recipe file not found in bundle")
		return nil
	}
	
	do {
		let data = try Data(contentsOf: bundleURL)
		let decoder = JSONDecoder()
		let recipe = try decoder.decode(RecipeInstructions.self, from: data)
		return recipe
	} catch {
		debugPrint("Error decoding coffee recipe: \(error)")
		return nil
	}
}
