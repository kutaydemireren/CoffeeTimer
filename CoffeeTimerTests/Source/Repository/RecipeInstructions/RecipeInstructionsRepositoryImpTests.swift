//
//  RecipeInstructionsRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

// TODO: move

func assertThrowsError<T>(
    act: () async throws -> T,
    _ catchError: (Error) -> Void
) async {
    do {
        _ = try await act()
        XCTFail("Error is expected to be thrown")
    } catch {
        catchError(error)
    }
}

//

final class MockNetworkManager: NetworkManager {
    var _error: Error!
    var _data: Data!
    var _request: Request!

    func perform(request: Request) throws -> Data {
        _request = request

        if let _error {
            throw _error
        }

        return _data
    }
}

//

final class MockDecoding: Decoding {
    var _error: Error!
    var _decoded: Any!
    var _data: Data!

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        _data = data

        if let _error {
            throw _error
        }

        return _decoded as! T
    }
}

//

final class RecipeInstructionsRepositoryImpTests: XCTestCase {
    let expectedSavedRecipeInstructionsKey = RecipeInstructionsConstants.savedRecipeInstructionsKey

    var mockStorage: MockStorage!
    var mockNetworkManager: MockNetworkManager!
    var mockDecoding: MockDecoding!
    var sut: RecipeInstructionsRepositoryImp!

    override func setUp() {
        mockStorage = MockStorage()
        mockNetworkManager = MockNetworkManager()
        mockNetworkManager._data = Data()
        mockDecoding = MockDecoding()
        mockDecoding._decoded = RecipeInstructions.empty
        sut = RecipeInstructionsRepositoryImp(
            networkManager: mockNetworkManager,
            decoding: mockDecoding,
            storage: mockStorage
        )
    }

    override func tearDown() {
        mockStorage = nil
        mockNetworkManager = nil
        mockDecoding = nil
        sut = nil
    }
}

// MARK: Fetch Instructions
extension RecipeInstructionsRepositoryImpTests {
    func test_fetchInstructions_whenNetworkThrowsError_shouldThrowExpectedError() async {
        mockNetworkManager._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetchInstructions(for: .frenchPress)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchInstructions_whenDecodingThrowsError_shouldThrowExpectedError() async {
        mockDecoding._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetchInstructions(for: .frenchPress)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchInstructions_shouldCreateExpectedBrewRequest() async throws {
        _ = try await sut.fetchInstructions(for: .frenchPress)

        XCTAssertEqual(try mockNetworkManager._request.createURLRequest(), try FetchRecipeInstructionsRequest(brewMethod: .frenchPress).createURLRequest())
    }

    func test_fetchInstructions_shouldReturnExpectedRecipeInstructions() async throws {
        mockNetworkManager._data = Data()
        let expectedInstructions = loadMiniInstructions()
        mockDecoding._decoded = expectedInstructions

        let resultedInstructions = try await sut.fetchInstructions(for: .frenchPress)

        XCTAssertEqual(resultedInstructions, expectedInstructions)
    }
}

// MARK: Save Instructions
extension RecipeInstructionsRepositoryImpTests {
    func test_save_shouldAppendToSavedRecipeInstructions() async throws {
        let existingInstructions = [RecipeInstructions(identifier: "test-id-1", steps: [.stubMessage, .stubPause])]
        mockStorage.storageDictionary[expectedSavedRecipeInstructionsKey] = existingInstructions

        let newInstruction = RecipeInstructions(
            identifier: "test-id-2",
            steps: [.stubPut, .stubMessage]
        )
        let expectedRecipeInstructions = existingInstructions + [newInstruction]

        try await sut.save(instructions: newInstruction)

        XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipeInstructionsKey)
        XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSavedRecipeInstructionsKey)
        XCTAssertEqual(mockStorage.saveCalledWithValue as? [RecipeInstructions], expectedRecipeInstructions)
    }
}
