//
//  RecipeMigrationTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/10/2025.
//

import XCTest
@testable import CoffeeTimer

final class RecipeMigrationTests: XCTestCase {
    var mockStorage: MockStorage!
    var sut: RecipeMigration!
    
    override func setUpWithError() throws {
        mockStorage = MockStorage()
        sut = RecipeMigration()
    }
}

// MARK: - Migrate Saved Recipes
extension RecipeMigrationTests {
    func test_migrate_whenRecipesHaveIDs_shouldNotModify() throws {
        let recipeDTO = RecipeDTO(
            id: UUID().uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let initialSaveKey = mockStorage.saveCalledWithKey
        mockStorage.storageDictionary[RecipeConstants.savedRecipesKey] = [recipeDTO]
        
        try sut.migrate(storage: mockStorage)
        
        // Should not save savedRecipes since no changes needed
        // (selectedRecipe might be saved separately if it exists, but we don't have one here)
        // The key point is that the saved recipes weren't modified
        let savedRecipes = mockStorage.storageDictionary[RecipeConstants.savedRecipesKey] as? [RecipeDTO]
        XCTAssertEqual(savedRecipes?.first?.id, recipeDTO.id)
    }
    
    func test_migrate_whenRecipesMissingIDs_shouldAddIDs() throws {
        let recipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary[RecipeConstants.savedRecipesKey] = [recipeDTO]
        
        try sut.migrate(storage: mockStorage)
        
        XCTAssertEqual(mockStorage.saveCalledWithKey, RecipeConstants.savedRecipesKey)
        let migratedDTOs = mockStorage.saveCalledWithValue as? [RecipeDTO]
        XCTAssertNotNil(migratedDTOs)
        XCTAssertEqual(migratedDTOs?.count, 1)
        XCTAssertNotNil(migratedDTOs?.first?.id)
        XCTAssertEqual(migratedDTOs?.first?.recipeProfile, recipeDTO.recipeProfile)
    }
    
    func test_migrate_whenSomeRecipesHaveIDs_shouldOnlyAddIDsToMissingOnes() throws {
        let recipeWithID = RecipeDTO(
            id: UUID().uuidString,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        let recipeWithoutID = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMiniIced.recipeProfile,
            ingredients: RecipeDTO.stubMiniIced.ingredients,
            brewQueue: RecipeDTO.stubMiniIced.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary[RecipeConstants.savedRecipesKey] = [recipeWithID, recipeWithoutID]
        
        try sut.migrate(storage: mockStorage)
        
        let migratedDTOs = mockStorage.saveCalledWithValue as? [RecipeDTO]
        XCTAssertNotNil(migratedDTOs)
        XCTAssertEqual(migratedDTOs?.count, 2)
        // First recipe should keep its ID
        XCTAssertEqual(migratedDTOs?.first?.id, recipeWithID.id)
        // Second recipe should get a new ID
        XCTAssertNotNil(migratedDTOs?.last?.id)
    }
}

// MARK: - Migrate Selected Recipe
extension RecipeMigrationTests {
    func test_migrate_whenSelectedRecipeHasID_shouldNotModify() throws {
        let recipeId = UUID().uuidString
        let selectedRecipeDTO = RecipeDTO(
            id: recipeId,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary[RecipeConstants.selectedRecipeKey] = selectedRecipeDTO
        
        try sut.migrate(storage: mockStorage)
        
        // Should not save selected recipe since it already has an ID
        // Verify the stored recipe still has the same ID
        let storedDTO = mockStorage.storageDictionary[RecipeConstants.selectedRecipeKey] as? RecipeDTO
        XCTAssertEqual(storedDTO?.id, recipeId)
    }
    
    func test_migrate_whenSelectedRecipeMissingID_shouldAddID() throws {
        let selectedRecipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary[RecipeConstants.selectedRecipeKey] = selectedRecipeDTO
        
        try sut.migrate(storage: mockStorage)
        
        XCTAssertEqual(mockStorage.saveCalledWithKey, RecipeConstants.selectedRecipeKey)
        let migratedDTO = mockStorage.saveCalledWithValue as? RecipeDTO
        XCTAssertNotNil(migratedDTO?.id)
        XCTAssertEqual(migratedDTO?.recipeProfile, selectedRecipeDTO.recipeProfile)
    }
    
    func test_migrate_whenSelectedRecipeMatchesSavedRecipe_shouldUseSameID() throws {
        // Create a saved recipe without ID
        let savedRecipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        // Create selected recipe with same content (but no ID)
        let selectedRecipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary = [
            RecipeConstants.savedRecipesKey: [savedRecipeDTO],
            RecipeConstants.selectedRecipeKey: selectedRecipeDTO
        ]
        
        try sut.migrate(storage: mockStorage)
        
        // Both should be saved
        let savedRecipes = mockStorage.saveCalls.filter { $0.key == RecipeConstants.savedRecipesKey }
        let selectedRecipeSaves = mockStorage.saveCalls.filter { $0.key == RecipeConstants.selectedRecipeKey }
        
        XCTAssertEqual(savedRecipes.count, 1)
        XCTAssertEqual(selectedRecipeSaves.count, 1)
        
        // Get the migrated DTOs
        let migratedSavedDTOs = mockStorage.storageDictionary[RecipeConstants.savedRecipesKey] as? [RecipeDTO]
        let migratedSelectedDTO = mockStorage.storageDictionary[RecipeConstants.selectedRecipeKey] as? RecipeDTO
        
        XCTAssertNotNil(migratedSavedDTOs?.first?.id)
        XCTAssertNotNil(migratedSelectedDTO?.id)
        
        // Selected recipe should have the same ID as the saved recipe
        XCTAssertEqual(migratedSelectedDTO?.id, migratedSavedDTOs?.first?.id, "Selected recipe should match saved recipe ID")
    }
    
    func test_migrate_whenSelectedRecipeDoesNotMatchSavedRecipe_shouldUseDifferentID() throws {
        // Create a saved recipe without ID
        let savedRecipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMini.recipeProfile,
            ingredients: RecipeDTO.stubMini.ingredients,
            brewQueue: RecipeDTO.stubMini.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        // Create selected recipe with different content
        let selectedRecipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: RecipeDTO.stubMiniIced.recipeProfile,
            ingredients: RecipeDTO.stubMiniIced.ingredients,
            brewQueue: RecipeDTO.stubMiniIced.brewQueue,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        
        mockStorage.storageDictionary = [
            RecipeConstants.savedRecipesKey: [savedRecipeDTO],
            RecipeConstants.selectedRecipeKey: selectedRecipeDTO
        ]
        
        try sut.migrate(storage: mockStorage)
        
        // Get the migrated DTOs
        let migratedSavedDTOs = mockStorage.storageDictionary[RecipeConstants.savedRecipesKey] as? [RecipeDTO]
        let migratedSelectedDTO = mockStorage.storageDictionary[RecipeConstants.selectedRecipeKey] as? RecipeDTO
        
        XCTAssertNotNil(migratedSavedDTOs?.first?.id)
        XCTAssertNotNil(migratedSelectedDTO?.id)
        
        // Selected recipe should have a different ID than the saved recipe
        XCTAssertNotEqual(migratedSelectedDTO?.id, migratedSavedDTOs?.first?.id, "Selected recipe should have different ID when content doesn't match")
    }
}

