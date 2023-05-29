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

	var saveCalledWithKey: String?
	var saveCalledWithValue: Any?

	var loadCalledWithKey: String?

	func save<T>(_ value: T?, forKey key: String) {
		saveCalledWithKey = key
		saveCalledWithValue = value
		storageDictionary[key] = value
	}

	func load<T>(forKey key: String) -> T? {
		loadCalledWithKey = key
		return storageDictionary[key] as? T
	}
}

final class MockRecipeMapper: RecipeMapper {
	var mapToRecipeCalled = false
	var mapToRecipeReceivedRecipeDTO: RecipeDTO?

	var recipesDict: [Int: Recipe] = [:]
	var recipeDTOsDict: [Int: RecipeDTO] = [:]

	var mapToRecipeDTOCalled = false
	var mapToRecipeDTOReceivedRecipe: Recipe?

	func mapToRecipe(recipeDTO: RecipeDTO) -> Recipe {
		mapToRecipeCalled = true
		mapToRecipeReceivedRecipeDTO = recipeDTO

		let firstMatchingIndex = recipeDTOsDict.filter { (_, value) in
			return value == recipeDTO
		}.keys.first!

		return recipesDict[firstMatchingIndex] ?? .stubSingleV60
	}

	func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO {
		mapToRecipeDTOCalled = true
		mapToRecipeDTOReceivedRecipe = recipe

		let firstMatchingIndex = recipesDict.filter { (_, value) in
			return value == recipe

		}.keys.first!

		return recipeDTOsDict[firstMatchingIndex] ?? .stub
	}
}

final class RecipeRepositoryTests: XCTestCase {

	let expectedSelectedRecipeKey = RecipeConstants.selectedRecipeKey
	let expectedSavedRecipesKey = RecipeConstants.savedRecipesKey

	var mockStorage: MockStorage!
	var mockMapper: MockRecipeMapper!
	var sut: RecipeRepositoryImp!

	override func setUpWithError() throws {
		mockStorage = MockStorage()
		mockMapper = MockRecipeMapper()
		sut = RecipeRepositoryImp(storage: mockStorage, mapper: mockMapper)
	}

	func test_getSelectedRecipe_shouldReturnExpectedRecipe() {
		let expectedRecipeDTO = RecipeDTO.stubMini
		mockStorage.storageDictionary = [expectedSelectedRecipeKey: expectedRecipeDTO]

		let expectedRecipe = Recipe.stubMini
		setupMapperReturn(expectedRecipeDTOs: [expectedRecipeDTO], expectedRecipes: [expectedRecipe])

		let resultedRecipe = sut.getSelectedRecipe()

		XCTAssertEqual(resultedRecipe, expectedRecipe)
		XCTAssertTrue(mockMapper.mapToRecipeCalled)
		XCTAssertEqual(mockMapper.mapToRecipeReceivedRecipeDTO, expectedRecipeDTO)
	}

	func test_getSavedRecipes_shouldReturnExpectedRecipes() {
		let expectedRecipeDTOs = MockStore.savedRecipeDTOs
		mockStorage.storageDictionary = [expectedSavedRecipesKey: expectedRecipeDTOs]

		let expectedRecipes = MockStore.savedRecipes
		setupMapperReturn(expectedRecipeDTOs: expectedRecipeDTOs, expectedRecipes: expectedRecipes)

		let resultedRecipes = sut.getSavedRecipes()

		XCTAssertEqual(resultedRecipes, expectedRecipes)
		XCTAssertTrue(mockMapper.mapToRecipeCalled)
		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
	}

	func test_save_shouldAppendToSavedRecipes() {
		let alreadySavedRecipeDTOs = MockStore.savedRecipeDTOs
		mockStorage.storageDictionary = [expectedSavedRecipesKey: alreadySavedRecipeDTOs]

		let saveRecipe = Recipe.stubMini
		let saveRecipeDTO = RecipeDTO.stubMini

		let expectedRecipeDTOs = alreadySavedRecipeDTOs + [saveRecipeDTO]
		let expectedRecipes = MockStore.savedRecipes + [saveRecipe]
		setupMapperReturn(expectedRecipeDTOs: expectedRecipeDTOs, expectedRecipes: expectedRecipes)

		sut.save(saveRecipe)

		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
		XCTAssertEqual(mockStorage.load(forKey: expectedSavedRecipesKey), expectedRecipeDTOs)
		XCTAssertTrue(mockMapper.mapToRecipeDTOCalled)
		XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, saveRecipe)
		XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSavedRecipesKey)
		XCTAssertEqual(mockStorage.saveCalledWithValue as? [RecipeDTO], expectedRecipeDTOs)
	}
}

extension RecipeRepositoryTests {
	private func setupMapperReturn(expectedRecipeDTOs: [RecipeDTO], expectedRecipes: [Recipe]) {
		zip(expectedRecipeDTOs, expectedRecipes).enumerated().forEach { (index, zip) in
			let (recipeDTO, recipe) = zip

			mockMapper.recipesDict[index] = recipe
			mockMapper.recipeDTOsDict[index] = recipeDTO
		}
	}
}
