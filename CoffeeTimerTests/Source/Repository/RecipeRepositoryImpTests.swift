//
//  RecipeRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 11/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class MockStorage: Storage {
	var storageDictionary: [String: Any] = [:]

	func save<T>(_ value: T?, forKey key: String) {
		storageDictionary[key] = value
	}

	func load<T>(forKey key: String) -> T? {
		return storageDictionary[key] as? T
	}
}

final class RecipeRepositoryTests: XCTestCase {

	let expectedSelectedRecipeKey = RecipeConstants.selectedRecipeKey
	let expectedSavedRecipesKey = RecipeConstants.savedRecipesKey

	var mockStorage: MockStorage!
	var sut: RecipeRepositoryImp!

	override func setUpWithError() throws {
		mockStorage = MockStorage()
		sut = RecipeRepositoryImp(storage: mockStorage)
	}

	func test_getSelectedRecipe_shouldReturnExpectedRecipe() {
		let expectedRecipe = Recipe.stubSingleV60
		mockStorage.storageDictionary = [expectedSelectedRecipeKey: expectedRecipe]

		let resultedRecipe = sut.getSelectedRecipe()

		XCTAssertEqual(resultedRecipe, expectedRecipe)
	}

	func test_getSavedRecipes_shouldReturnExpectedRecipes() {
		let expectedRecipes = MockStore.savedRecipes
		mockStorage.storageDictionary = [expectedSavedRecipesKey: expectedRecipes]

		let resultedRecipes = sut.getSavedRecipes()

		XCTAssertEqual(resultedRecipes, expectedRecipes)
	}

	func test_save_shouldAppendToSavedRecipes() {
		let alreadySavedRecipes = MockStore.savedRecipes
		mockStorage.storageDictionary = [expectedSavedRecipesKey: alreadySavedRecipes]
		let saveRecipe = Recipe.stubSingleV60
		let expectedRecipes = alreadySavedRecipes + [saveRecipe]

		sut.save(saveRecipe)
		
		XCTAssertEqual(mockStorage.load(forKey: expectedSavedRecipesKey), expectedRecipes)
	}
}
