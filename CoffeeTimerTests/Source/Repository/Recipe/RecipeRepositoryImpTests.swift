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
        XCTAssertTrue(mockStorage.loadCalls.contains(expectedSelectedRecipeKey))
    }
    
    func test_getSelectedRecipe_shouldReturnExpectedRecipe() {
        let expectedRecipeDTO = RecipeDTO.stubMini
        mockStorage.storageDictionary = [
            expectedSelectedRecipeKey: expectedRecipeDTO,
            expectedSavedRecipesKey: [expectedRecipeDTO]
        ]
        
        // Create a Recipe with the same ID as the DTO so they match
        guard let recipeId = expectedRecipeDTO.id, let uuid = UUID(uuidString: recipeId) else {
            XCTFail("RecipeDTO should have a valid ID")
            return
        }
        
        let expectedRecipe = Recipe(
            id: uuid,
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        // Setup mapper to handle both refreshSavedRecipes (loads saved recipes) and getSelectedRecipe (loads selected recipe)
        // Both load the same DTO, so mapper should return the same recipe for both
        // When refreshSavedRecipes runs, it loads savedRecipes and maps them
        // When getSelectedRecipe runs, it calls refreshSavedRecipes again, then matches by ID
        setupMapperReturn(expectedRecipeDTOs: [expectedRecipeDTO, expectedRecipeDTO], expectedRecipes: [expectedRecipe, expectedRecipe])
        
        let resultedRecipe = sut.getSelectedRecipe()
        
        XCTAssertEqual(resultedRecipe, expectedRecipe)
        XCTAssertTrue(mockStorage.loadCalls.contains(expectedSelectedRecipeKey))
    }
    
    func test_getSelectedRecipe_whenSelectedRecipeMatchesSavedRecipe_shouldReturnRecipe() {
        // Selected recipe matches a saved recipe by ID
        let recipeId = UUID()
        
        let selectedRecipeDTO = RecipeDTO(
            id: recipeId.uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let savedRecipeDTO = RecipeDTO(
            id: recipeId.uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary = [
            expectedSelectedRecipeKey: selectedRecipeDTO,
            expectedSavedRecipesKey: [savedRecipeDTO]
        ]
        
        let recipe = Recipe(
            id: recipeId,
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        setupMapperReturn(expectedRecipeDTOs: [savedRecipeDTO, selectedRecipeDTO], expectedRecipes: [recipe, recipe])
        
        let resultedRecipe = sut.getSelectedRecipe()
        
        XCTAssertNotNil(resultedRecipe)
        XCTAssertEqual(resultedRecipe?.id, recipeId)
    }
    
    func test_getSelectedRecipe_whenSelectedRecipeNotInList_shouldReturnNil() {
        let selectedRecipeDTO = RecipeDTO.stubMini
        let differentRecipeDTO = RecipeDTO.stubMiniIced
        
        mockStorage.storageDictionary = [
            expectedSelectedRecipeKey: selectedRecipeDTO,
            expectedSavedRecipesKey: [differentRecipeDTO]
        ]
        
        let selectedRecipe = Recipe.stubMini
        let differentRecipe = Recipe.stubMiniIced
        setupMapperReturn(expectedRecipeDTOs: [selectedRecipeDTO, differentRecipeDTO], expectedRecipes: [selectedRecipe, differentRecipe])
        
        let resultedRecipe = sut.getSelectedRecipe()
        
        // Selected recipe is not in the saved recipes list, so should return nil
        XCTAssertNil(resultedRecipe)
    }
    
    func test_getSelectedRecipe_whenMultipleRecipesWithSameName_shouldMatchByIDOnly() {
        // Create two recipes with same name and brew method but different IDs
        let recipe1Id = UUID()
        let recipe2Id = UUID()
        
        let recipe1 = Recipe(
            id: recipe1Id,
            recipeProfile: .stubMini,
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let recipe2 = Recipe(
            id: recipe2Id,
            recipeProfile: .stubMini, // Same name and brew method
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 15, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 300, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let recipe1DTO = RecipeDTO(
            id: recipe1Id.uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
            ],
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let recipe2DTO = RecipeDTO(
            id: recipe2Id.uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile, // Same name and brew method
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 15, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 300, type: .millilitre))
            ],
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        // Select recipe2 (the second one)
        mockStorage.storageDictionary = [
            expectedSelectedRecipeKey: recipe2DTO,
            expectedSavedRecipesKey: [recipe1DTO, recipe2DTO]
        ]
        
        setupMapperReturn(expectedRecipeDTOs: [recipe1DTO, recipe2DTO], expectedRecipes: [recipe1, recipe2])
        
        let resultedRecipe = sut.getSelectedRecipe()
        
        // Should match recipe2 by ID, not recipe1 (even though they have the same name)
        XCTAssertNotNil(resultedRecipe)
        XCTAssertEqual(resultedRecipe?.id, recipe2Id)
        XCTAssertEqual(resultedRecipe?.ingredients.first?.amount.amount, 15) // recipe2's coffee amount
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

// MARK: Update Saved Recipe
extension RecipeRepositoryTests {
    func test_updateSavedRecipe_whenRecipeNotExistsInSaved_shouldNotSave() {
        let updateRecipe = Recipe.stubMini
        let updateRecipeDTO = RecipeDTO.stubMini
        
        let alreadySavedRecipeDTOs = MockStore.savedRecipeDTOs
        mockStorage.storageDictionary = [expectedSavedRecipesKey: alreadySavedRecipeDTOs]
        
        setupMapperReturn(expectedRecipeDTOs: [updateRecipeDTO], expectedRecipes: [updateRecipe])
        
        sut.update(savedRecipe: updateRecipe)
        
        XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
        XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, updateRecipe)
        // Check that savedRecipes was NOT saved (since recipe doesn't exist)
        let savedRecipesKeyCalls = mockStorage.saveCalls.filter { $0.key == expectedSavedRecipesKey }
        XCTAssertEqual(savedRecipesKeyCalls.count, 0, "Should not save savedRecipes when recipe doesn't exist")
    }
    
    func test_updateSavedRecipe_whenRecipeExistsByID_shouldUpdateInSavedRecipes() {
        let recipeId = UUID()
        let updateRecipe = Recipe(
            id: recipeId,
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        let updateRecipeDTO = RecipeDTO(
            id: recipeId.uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let alreadySavedRecipeDTOs = MockStore.savedRecipeDTOs + [updateRecipeDTO]
        mockStorage.storageDictionary = [expectedSavedRecipesKey: alreadySavedRecipeDTOs]
        
        var expectedRecipeDTOs = MockStore.savedRecipeDTOs
        expectedRecipeDTOs.append(updateRecipeDTO)
        
        setupMapperReturn(expectedRecipeDTOs: [updateRecipeDTO], expectedRecipes: [updateRecipe])
        
        sut.update(savedRecipe: updateRecipe)
        
        XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipesKey)
        XCTAssertEqual(mockMapper.mapToRecipeDTOReceivedRecipe, updateRecipe)
        XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSavedRecipesKey)
        
        let savedDTOs = mockStorage.saveCalledWithValue as? [RecipeDTO]
        XCTAssertNotNil(savedDTOs)
        if let savedDTOs {
            let updatedDTO = savedDTOs.first(where: { $0.id == recipeId.uuidString })
            XCTAssertEqual(updatedDTO?.id, recipeId.uuidString)
        }
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
        // Check that savedRecipes was NOT saved (since recipe doesn't exist)
        let savedRecipesKeyCalls = mockStorage.saveCalls.filter { $0.key == expectedSavedRecipesKey }
        XCTAssertEqual(savedRecipesKeyCalls.count, 0, "Should not save savedRecipes when recipe doesn't exist")
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
