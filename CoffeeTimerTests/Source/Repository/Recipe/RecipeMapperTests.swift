//
//  RecipeMapperTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 21/05/2023.
//

import XCTest
@testable import CoffeeTimer

extension RecipeDTO {
	static var stub: RecipeDTO {
		return .init(
			recipeProfile: .init(name: "an arbitrary name", icon: .init(title: "icon title", colorHex: "color hex", imageName: "image name")),
			ingredients: [
				.init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
				.init(ingredientType: .water, amount: .init(amount: 15, type: .millilitre)),
				.init(ingredientType: .coffee, amount: .init(amount: 20, type: .spoon))
			],
			brewQueue: .init(stages: [
				.init(action: .pour(water: .init(amount: 10, type: .spoon)), requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .userInteractive),
				.init(action: .pause, requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto),
				.init(action: .swirl, requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .auto)
			])
		)
	}
}


final class RecipeMapperTests: XCTestCase {
	var sut: RecipeMapper

    override func setUpWithError() throws {
		sut = RecipeMapper()
    }

    func test_mapToRecipe_shouldMapAsExpected() throws {
		let expectedRecipe = 

		let recipe = sut.mapToRecipe(recipeDTO: .stub)

		XCTAssert(recipe, )
    }
}


