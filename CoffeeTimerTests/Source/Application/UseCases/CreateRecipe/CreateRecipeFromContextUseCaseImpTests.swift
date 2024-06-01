//
//  CreateRecipeFromContextUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateRecipeFromContextUseCaseImpTests: XCTestCase {
    var mockCreateContextToInputMapper: MockCreateContextToInputMapper!
    var mockFetchRecipeInstructionsUseCase: MockFetchRecipeInstructionsUseCase!
    var mockCreateRecipeFromInputUseCase: MockCreateRecipeFromInputUseCase!
    var sut: CreateRecipeFromContextUseCaseImp!

    var validContext: CreateRecipeContext {
        let createRecipeContext = CreateRecipeContext()
        createRecipeContext.selectedBrewMethod = .frenchPress
        createRecipeContext.recipeProfile = .stubMini
        createRecipeContext.cupsCount = 1
        createRecipeContext.ratio = .ratio15

        return createRecipeContext
    }

    override func setUpWithError() throws {
        mockCreateContextToInputMapper = MockCreateContextToInputMapper()
        mockCreateContextToInputMapper._input = .stubSingleV60
        mockFetchRecipeInstructionsUseCase = MockFetchRecipeInstructionsUseCase()
        mockCreateRecipeFromInputUseCase = MockCreateRecipeFromInputUseCase()

        sut = CreateRecipeFromContextUseCaseImp(
            createContextToInputMapper: mockCreateContextToInputMapper,
            fetchRecipeInstructionsUseCase: mockFetchRecipeInstructionsUseCase,
            createRecipeFromInputUseCase: mockCreateRecipeFromInputUseCase
        )
    }
}

// MARK: - Can Create
extension CreateRecipeFromContextUseCaseImpTests {
    func test_canCreate_whenSelectedBrewMethodIsNil_shouldThrowMissingBrewMethod() {
        let createRecipeContext = CreateRecipeContext()

        var thrownError: Error?
        do {
            let _ = try sut.canCreate(from: createRecipeContext)
        } catch let error {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? CreateRecipeFromContextUseCaseError, CreateRecipeFromContextUseCaseError.missingBrewMethod)
    }

    func test_canCreate_whenRecipeProfileHasNoContent_shouldThrowMissingRecipeProfile() {
        let createRecipeContext = CreateRecipeContext()
        createRecipeContext.selectedBrewMethod = .frenchPress

        var thrownError: Error?
        do {
            let _ = try sut.canCreate(from: createRecipeContext)
        } catch let error {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? CreateRecipeFromContextUseCaseError, CreateRecipeFromContextUseCaseError.missingRecipeProfile)
    }

    func test_canCreate_whenCupsCountIsNotGreaterThanZero_shouldThrowMissingCupsCount() {
        let createRecipeContext = CreateRecipeContext()
        createRecipeContext.selectedBrewMethod = .frenchPress
        createRecipeContext.recipeProfile = .stubMini

        var thrownError: Error?
        do {
            let _ = try sut.canCreate(from: createRecipeContext)
        } catch let error {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? CreateRecipeFromContextUseCaseError, CreateRecipeFromContextUseCaseError.missingCupsCount)
    }

    func test_canCreate_whenRatioIsNil_shouldThrowMissingRatio() {
        let createRecipeContext = CreateRecipeContext()
        createRecipeContext.selectedBrewMethod = .frenchPress
        createRecipeContext.recipeProfile = .stubMini
        createRecipeContext.cupsCount = 1

        var thrownError: Error?
        do {
            let _ = try sut.canCreate(from: createRecipeContext)
        } catch let error {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? CreateRecipeFromContextUseCaseError, CreateRecipeFromContextUseCaseError.missingRatio)
    }

    func test_canCreate_whenContextIsAllSet_shouldReturnTrue() {
        var resultedCanCreate: Bool = false

        var thrownError: Error?
        do {
            resultedCanCreate = try sut.canCreate(from: validContext)
        } catch let error {
            thrownError = error
        }

        XCTAssertTrue(resultedCanCreate)
        XCTAssertNil(thrownError)
    }
}

// MARK: - Create
extension CreateRecipeFromContextUseCaseImpTests {
    func test_create_whenMissingContext_shouldReturnNil() {
        let resultedRecipe = sut.create(from: CreateRecipeContext())

        XCTAssertNil(resultedRecipe)
    }

    func test_create_whenMappingToInputFails_shouldReturnNil() {
        mockCreateContextToInputMapper._error = TestError.notAllowed

        let resultedRecipe = sut.create(from: validContext)

        XCTAssertNil(resultedRecipe)
    }

    func test_create_whenFetchRecipeInstructionsFails_shouldReturnNil() {
        mockFetchRecipeInstructionsUseCase._error = TestError.notAllowed

        let resultedRecipe = sut.create(from: validContext)

        XCTAssertNil(resultedRecipe)
    }

    func test_create_shouldReturnExpectedRecipe() {
        let expectedRecipe = Recipe.stubSingleV60
        mockCreateRecipeFromInputUseCase._recipe = expectedRecipe

        let resultedRecipe = sut.create(from: validContext)

        XCTAssertEqual(resultedRecipe, expectedRecipe)
    }
}
