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

    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions {
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
}
