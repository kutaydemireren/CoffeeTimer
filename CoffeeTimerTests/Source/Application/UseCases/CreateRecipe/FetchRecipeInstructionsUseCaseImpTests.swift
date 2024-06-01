//
//  FetchRecipeInstructionsUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

// TODO: move

final class MockRecipeInstructionsRepository: RecipeInstructionsRepository {
    var _error: Error!
    var _recipeInstructions: RecipeInstructions!
    var _brewMethod: BrewMethod!

    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions {
        _brewMethod = brewMethod

        if let _error {
            throw _error
        }

        return _recipeInstructions
    }
}

//

final class FetchRecipeInstructionsUseCaseImpTests: XCTestCase {
    var mockRepository: MockRecipeInstructionsRepository!
    var sut: FetchRecipeInstructionsUseCaseImp!

    override func setUp() {
        mockRepository = MockRecipeInstructionsRepository()
        sut = FetchRecipeInstructionsUseCaseImp(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
    }

    func test_fetch_whenErrorThrown_shouldThrowExpectedError() {
        mockRepository._error = TestError.notAllowed

        XCTAssertThrowsError(try sut.fetch(brewMethod: .frenchPress)) { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetch_shouldRequestExpectedBrewMethod() throws {
        let expectedBrewMethod = BrewMethod.frenchPress
        mockRepository._recipeInstructions = loadV60SingleRecipeInstructions()

        _ = try sut.fetch(brewMethod: expectedBrewMethod)

        XCTAssertEqual(mockRepository._brewMethod, expectedBrewMethod)
    }

    func test_fetch_shouldRequestExpectedInstructions() throws {
        let expectedInstructions = loadV60SingleRecipeInstructions()
        mockRepository._recipeInstructions = expectedInstructions

        let resultedInstructions = try sut.fetch(brewMethod: .frenchPress)

        XCTAssertEqual(resultedInstructions, expectedInstructions)
    }
}
