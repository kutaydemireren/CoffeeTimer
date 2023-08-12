//
//  RecipeRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 11/05/2023.
//

import XCTest
@testable import CoffeeTimer
import Combine

final class RecipeRepositoryTests: XCTestCase {
	let expectedSelectedRecipeKey = RecipeConstants.selectedRecipeKey
	let expectedSavedRecipesKey = RecipeConstants.savedRecipesKey

	var mockStorage: MockStorage!
	var mockMapper: MockRecipeMapper!
	var sut: RecipeRepositoryImp!
	private var cancellables: [AnyCancellable] = []

	override func setUpWithError() throws {
		mockStorage = MockStorage()
		mockMapper = MockRecipeMapper()
		sut = RecipeRepositoryImp(storage: mockStorage, mapper: mockMapper)
	}
}

// MARK: Selected Recipe
extension RecipeRepositoryTests {
	func test_getSelectedRecipe_whenNotExists_shouldReturnNil() {
		setupMapperReturn(expectedRecipeDTOs: [], expectedRecipes: [])

		let resultedRecipe = sut.getSelectedRecipe()

		XCTAssertNil(resultedRecipe)
		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSelectedRecipeKey)
		XCTAssertNil(mockMapper.mapToRecipeReceivedRecipeDTO)
	}

	func test_getSelectedRecipe_whenMapperFails_shouldReturnNil() {
		let expectedRecipeDTO = RecipeDTO.stubMini
		mockStorage.storageDictionary = [expectedSelectedRecipeKey: expectedRecipeDTO]

		setupMapperReturn(expectedRecipeDTOs: [], expectedRecipes: [])

		let resultedRecipe = sut.getSelectedRecipe()

		XCTAssertNil(resultedRecipe)
		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSelectedRecipeKey)
		XCTAssertEqual(mockMapper.mapToRecipeReceivedRecipeDTO, expectedRecipeDTO)
	}

	func test_getSelectedRecipe_shouldReturnExpectedRecipe() {
		let expectedRecipeDTO = RecipeDTO.stubMini
		mockStorage.storageDictionary = [expectedSelectedRecipeKey: expectedRecipeDTO]

		let expectedRecipe = Recipe.stubMini
		setupMapperReturn(expectedRecipeDTOs: [expectedRecipeDTO], expectedRecipes: [expectedRecipe])

		let resultedRecipe = sut.getSelectedRecipe()

		XCTAssertEqual(resultedRecipe, expectedRecipe)
		XCTAssertEqual(mockMapper.mapToRecipeReceivedRecipeDTO, expectedRecipeDTO)
	}

	func test_updateSelectedRecipe_shouldUpdateSelectedRecipe() {
		let expectedRecipeDTO = RecipeDTO.stubMini
		mockStorage.storageDictionary = [expectedSelectedRecipeKey: expectedRecipeDTO]

		let expectedRecipe = Recipe.stubMini
		setupMapperReturn(expectedRecipeDTOs: [expectedRecipeDTO], expectedRecipes: [expectedRecipe])

		sut.update(selectedRecipe: expectedRecipe)

		XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, expectedRecipe)
		XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSelectedRecipeKey)
		XCTAssertEqual(mockStorage.saveCalledWithValue as? RecipeDTO, expectedRecipeDTO)
	}
}

// MARK: Save(d) Recipe(s)
extension RecipeRepositoryTests {
	func test_recipesPublisher_whenInitialised_shouldBeUpToDate() {
		let expectedRecipeDTOs = MockStore.savedRecipeDTOs
		mockStorage.storageDictionary = [expectedSavedRecipesKey: expectedRecipeDTOs]

		let expectedRecipes = MockStore.savedRecipes
		setupMapperReturn(expectedRecipeDTOs: expectedRecipeDTOs, expectedRecipes: expectedRecipes)

		let expectation = expectation(description: "Should get saved recipes")
		sut = RecipeRepositoryImp(storage: mockStorage, mapper: mockMapper)

		var resultedRecipes: [Recipe] = []
		sut.recipesPublisher
			.sink { savedRecipes in
				resultedRecipes.append(contentsOf: savedRecipes)
				expectation.fulfill()
			}
			.store(in: &cancellables)

		wait(for: [expectation], timeout: 1.0)

		XCTAssertEqual(resultedRecipes, expectedRecipes)
		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
	}

	func test_recipesPublisher_whenOneMappingFails_shouldReturnExpectedRecipesWithoutFailedOne() {
		let expectedRecipeDTOs = MockStore.savedRecipeDTOs
		mockStorage.storageDictionary = [expectedSavedRecipesKey: expectedRecipeDTOs]

		var expectedRecipes = MockStore.savedRecipes
		expectedRecipes.removeLast()
		setupMapperReturn(expectedRecipeDTOs: expectedRecipeDTOs, expectedRecipes: expectedRecipes)

		let expectation = expectation(description: "Should get only non-failing saved recipes")
		sut = RecipeRepositoryImp(storage: mockStorage, mapper: mockMapper)

		var resultedRecipes: [Recipe] = []
		sut.recipesPublisher
			.sink { savedRecipes in
				resultedRecipes.append(contentsOf: savedRecipes)
				expectation.fulfill()
			}
			.store(in: &cancellables)

		wait(for: [expectation], timeout: 1.0)

		XCTAssertEqual(resultedRecipes, expectedRecipes)
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
		XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, saveRecipe)
		XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSavedRecipesKey)
		XCTAssertEqual(mockStorage.saveCalledWithValue as? [RecipeDTO], expectedRecipeDTOs)
	}
}

// MARK: Remove
extension RecipeRepositoryTests {
	func test_removeRecipe_whenRecipeNotExistsInSaved_shouldNotSave() {
		let removeRecipe = Recipe.stubMini
		let removeRecipeDTO = RecipeDTO.stubMini

		let alreadySavedRecipeDTOs = MockStore.savedRecipeDTOs
		mockStorage.storageDictionary = [expectedSavedRecipesKey: alreadySavedRecipeDTOs]

		setupMapperReturn(expectedRecipeDTOs: [removeRecipeDTO], expectedRecipes: [removeRecipe])

		sut.remove(recipe: removeRecipe)

		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
		XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, removeRecipe)
		XCTAssertNil(mockStorage.saveCalledWithKey)
		XCTAssertNil(mockStorage.saveCalledWithValue)
	}

	func test_removeRecipe_shouldRemoveFromSavedRecipes() {
		let removeRecipe = Recipe.stubMini
		let removeRecipeDTO = RecipeDTO.stubMini

		let expectedRecipeDTOs = MockStore.savedRecipeDTOs
		let alreadySavedRecipeDTOs = expectedRecipeDTOs + [removeRecipeDTO]
		mockStorage.storageDictionary = [expectedSavedRecipesKey: alreadySavedRecipeDTOs]
		setupMapperReturn(expectedRecipeDTOs: [removeRecipeDTO], expectedRecipes: [removeRecipe])

		sut.remove(recipe: removeRecipe)

		XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
		XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, removeRecipe)
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
