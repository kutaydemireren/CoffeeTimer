//
//  UpdateRecipeFromContextUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/10/2025.
//

import XCTest
@testable import CoffeeTimer

final class UpdateRecipeFromContextUseCaseImpTests: XCTestCase {
    var mockCreateContextToInputMapper: MockCreateContextToInputMapper!
    var mockFetchRecipeInstructionsUseCase: MockFetchRecipeInstructionsUseCase!
    var mockCreateRecipeFromInputUseCase: MockCreateRecipeFromInputUseCase!
    var mockRecipeRepository: MockRecipeRepository!
    var sut: UpdateRecipeFromContextUseCaseImp!
    
    var validContext: CreateRecipeContext {
        let context = CreateRecipeContext()
        context.selectedBrewMethod = .frenchPress()
        context.recipeProfile = .stubMini
        context.cupsCount = 1
        context.ratio = .ratio16
        return context
    }
    
    override func setUpWithError() throws {
        mockCreateContextToInputMapper = MockCreateContextToInputMapper()
        mockCreateContextToInputMapper._input = .stubSingleV60
        mockFetchRecipeInstructionsUseCase = MockFetchRecipeInstructionsUseCase()
        mockCreateRecipeFromInputUseCase = MockCreateRecipeFromInputUseCase()
        mockRecipeRepository = MockRecipeRepository()
        
        sut = UpdateRecipeFromContextUseCaseImp(
            createContextToInputMapper: mockCreateContextToInputMapper,
            fetchRecipeInstructionsUseCase: mockFetchRecipeInstructionsUseCase,
            createRecipeFromInputUseCase: mockCreateRecipeFromInputUseCase,
            recipeRepository: mockRecipeRepository
        )
    }
}

// MARK: - Update
extension UpdateRecipeFromContextUseCaseImpTests {
    func test_update_whenSelectedBrewMethodIsNil_shouldReturnNil() async {
        let context = CreateRecipeContext()
        let recipeId = UUID()
        
        let resultedRecipe = await sut.update(recipeId: recipeId, from: context)
        
        XCTAssertNil(resultedRecipe)
        XCTAssertNil(mockRecipeRepository.updateSelectedRecipeCalledWith)
        XCTAssertNil(mockRecipeRepository.updateSavedRecipeCalledWith)
    }
    
    func test_update_whenMappingToInputFails_shouldReturnNil() async {
        mockCreateContextToInputMapper._error = TestError.notAllowed
        
        let resultedRecipe = await sut.update(recipeId: UUID(), from: validContext)
        
        XCTAssertNil(resultedRecipe)
        XCTAssertNil(mockRecipeRepository.updateSelectedRecipeCalledWith)
        XCTAssertNil(mockRecipeRepository.updateSavedRecipeCalledWith)
    }
    
    func test_update_whenFetchRecipeInstructionsFails_shouldReturnNil() async {
        mockFetchRecipeInstructionsUseCase._error = TestError.notAllowed
        
        let resultedRecipe = await sut.update(recipeId: UUID(), from: validContext)
        
        XCTAssertNil(resultedRecipe)
        XCTAssertNil(mockRecipeRepository.updateSelectedRecipeCalledWith)
        XCTAssertNil(mockRecipeRepository.updateSavedRecipeCalledWith)
    }
    
    func test_update_shouldPreserveRecipeId() async {
        let recipeId = UUID()
        let expectedRecipe = Recipe.stubSingleV60
        mockCreateRecipeFromInputUseCase._recipe = expectedRecipe
        
        let resultedRecipe = await sut.update(recipeId: recipeId, from: validContext)
        
        XCTAssertEqual(resultedRecipe, expectedRecipe)
        XCTAssertEqual(mockCreateContextToInputMapper.mapReceivedContext?.recipeProfile, validContext.recipeProfile)
    }
    
    func test_update_shouldUpdateSelectedRecipe() async {
        let recipeId = UUID()
        let expectedRecipe = Recipe.stubSingleV60
        mockCreateRecipeFromInputUseCase._recipe = expectedRecipe
        
        _ = await sut.update(recipeId: recipeId, from: validContext)
        
        XCTAssertEqual(mockRecipeRepository.updateSelectedRecipeCalledWith, expectedRecipe)
    }
    
    func test_update_shouldUpdateSavedRecipe() async {
        let recipeId = UUID()
        let expectedRecipe = Recipe.stubSingleV60
        mockCreateRecipeFromInputUseCase._recipe = expectedRecipe
        
        _ = await sut.update(recipeId: recipeId, from: validContext)
        
        XCTAssertEqual(mockRecipeRepository.updateSavedRecipeCalledWith, expectedRecipe)
    }
}

