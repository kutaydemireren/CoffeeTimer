//
//  RecipeRepositoryTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 11/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class RecipeRepositoryTests: XCTestCase {

	var sut: RecipeRepositoryImp!

	override func setUpWithError() throws {
		sut = RecipeRepositoryImp()
	}

	func test_getSavedRecipes_shouldReturnExpectedRecipes() {
		let expectedRecipes = MockStore.savedRecipes
		RecipeRepositoryImp.savedRecipes = expectedRecipes

		let resultedRecipes = sut.getSavedRecipes()

		XCTAssertEqual(resultedRecipes, expectedRecipes)
	}

	func test_save_shouldAppendToSavedRecipes() {
		let expectedRecipe = MockStore.savedRecipes.first!

		sut.save(expectedRecipe)
		
		XCTAssertEqual(RecipeRepositoryImp.savedRecipes.last, expectedRecipe)
	}
}
