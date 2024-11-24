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
    var _receivedRecipeInstructions: RecipeInstructions!
    var _resultedRecipeInstructions: RecipeInstructions!
    var _brewMethod: BrewMethod!

    func fetchInstructions(for brewMethod: BrewMethod) throws -> RecipeInstructions {
        _brewMethod = brewMethod

        if let _error {
            throw _error
        }

        return _resultedRecipeInstructions
    }

    func save(instructions: RecipeInstructions) async throws {
        _receivedRecipeInstructions = instructions

        if let _error {
            throw _error
        }
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

    func test_fetch_whenErrorThrown_shouldThrowExpectedError() async {
        mockRepository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetch(brewMethod: .frenchPress)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetch_shouldRequestExpectedBrewMethod() async throws {
        let expectedBrewMethod = BrewMethod.frenchPress
        mockRepository._resultedRecipeInstructions = loadMiniInstructions()

        _ = try await sut.fetch(brewMethod: expectedBrewMethod)

        XCTAssertEqual(mockRepository._brewMethod, expectedBrewMethod)
    }

    func test_fetch_shouldReturnExpectedInstructions() async throws {
        let expectedInstructions = loadMiniInstructions()
        mockRepository._resultedRecipeInstructions = expectedInstructions

        let resultedInstructions = try await sut.fetch(brewMethod: .frenchPress)

        XCTAssertEqual(resultedInstructions, expectedInstructions)
    }
}

extension FetchRecipeInstructionsUseCaseImpTests {
    
    func test_fetchActions_whenErrorThrown_shouldThrowExpectedError() async {
        mockRepository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetchActions(brewMethod: .frenchPress)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchActions_shouldRequestExpectedBrewMethod() async throws {
        let expectedBrewMethod = BrewMethod.frenchPress
        mockRepository._resultedRecipeInstructions = loadMiniInstructions()

        _ = try await sut.fetchActions(brewMethod: expectedBrewMethod)

        XCTAssertEqual(mockRepository._brewMethod, expectedBrewMethod)
    }

    func test_fetchActions_shouldReturnExpectedInstructionActions() async throws {
        mockRepository._resultedRecipeInstructions = loadMiniInstructions()

        let resultedInstructions = try await sut.fetchActions(brewMethod: .frenchPress)
        
        XCTAssertEqual(resultedInstructions, .stubMiniActions)
    }
}
