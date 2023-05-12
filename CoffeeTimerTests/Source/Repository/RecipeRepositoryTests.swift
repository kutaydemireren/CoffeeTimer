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

	func test_getSelectedRecipe_shouldReturnExpectedRecipe() {
		let expectedRecipe = Recipe.stubSingleV60
		RecipeRepositoryImp.selectedRecipe = expectedRecipe

		let resultedRecipe = sut.getSelectedRecipe()

		XCTAssertEqual(resultedRecipe, expectedRecipe)
	}

	func test_getSavedRecipes_shouldReturnExpectedRecipes() {
		let expectedRecipes = MockStore.savedRecipes
		RecipeRepositoryImp.savedRecipes = expectedRecipes

		let resultedRecipes = sut.getSavedRecipes()

		XCTAssertEqual(resultedRecipes, expectedRecipes)
	}

	func test_save_shouldAppendToSavedRecipes() {
		let alreadySavedRecipes = MockStore.savedRecipes
		let saveRecipe = Recipe.stubSingleV60
		let expectedRecipes = alreadySavedRecipes + [saveRecipe]
		RecipeRepositoryImp.savedRecipes = alreadySavedRecipes

		sut.save(saveRecipe)
		
		XCTAssertEqual(RecipeRepositoryImp.savedRecipes, expectedRecipes)
	}
}
