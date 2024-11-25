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
    var performCallCount: Int = 0

    func perform(request: Request) throws -> Data {
        performCallCount += 1
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

        return try (_decoded as? T) ?? (JSONDecoder().decode(T.self, from: data))
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
            try await sut.fetchInstructions(for: .frenchPress())
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchInstructions_whenDecodingThrowsError_shouldThrowExpectedError() async {
        mockDecoding._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetchInstructions(for: .frenchPress())
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchInstructions_shouldCreateExpectedBrewRequest() async throws {
        mockDecoding._decoded = RecipeInstructions.empty

        _ = try await sut.fetchInstructions(for: .frenchPress())

        XCTAssertEqual(try mockNetworkManager._request.createURLRequest(), try FetchRecipeInstructionsRequest(brewMethod: .frenchPress()).createURLRequest())
    }

    func test_fetchInstructions_whenBrewMethodHasNotCustomMethodPath_shouldReturnRemoteRecipeInstructions() async throws {
        let localInstructions = [loadMiniInstructions()]
        mockStorage.storageDictionary[expectedSavedRecipeInstructionsKey] = localInstructions
        let remoteInstructions = loadMiniInstructions()
        mockNetworkManager._data = try! JSONEncoder().encode(remoteInstructions)

        let resultedInstructions = try await sut.fetchInstructions(for: .frenchPress())

        XCTAssertEqual(resultedInstructions, remoteInstructions)
        XCTAssertEqual(mockStorage.loadCalledCount, 0)
        XCTAssertEqual(mockNetworkManager.performCallCount, 1)
    }

    func test_fetchInstructions_whenBrewMethodHasCustomMethodPath_PathNotFound_shouldThrowInvalidCustomMethod() async throws {
        var localInstructions = loadMiniInstructions()
        mockStorage.storageDictionary[expectedSavedRecipeInstructionsKey] = [localInstructions]
        let remoteInstructions = loadMiniInstructions()
        mockNetworkManager._data = try! JSONEncoder().encode(remoteInstructions)

        await assertThrowsError {
            try await sut.fetchInstructions(for: .frenchPress(path: "custom-method://test-id"))
        } _: { error in
            XCTAssertEqual(error as? RecipeInstructionsRepositoryError, .invalidCustomMethod)
        }

        XCTAssertEqual(mockStorage.loadCalledCount, 1)
        XCTAssertEqual(mockNetworkManager.performCallCount, 0)
    }

    func test_fetchInstructions_whenBrewMethodHasCustomMethodPath_PathFound_shouldReturnSavedRecipeInstructions() async throws {
        let localInstructions = RecipeInstructions(
            identifier: "test-id",
            steps: [.stubMessage, .stubPause, .stubPut]
        )
        mockStorage.storageDictionary[expectedSavedRecipeInstructionsKey] = [localInstructions]
        let remoteInstructions = loadMiniInstructions()
        mockNetworkManager._data = try! JSONEncoder().encode(remoteInstructions)

        let resultedInstructions = try await sut.fetchInstructions(for: .frenchPress(path: "custom-method://test-id"))

        XCTAssertEqual(resultedInstructions, localInstructions)
        XCTAssertEqual(mockStorage.loadCalledCount, 1)
        XCTAssertEqual(mockNetworkManager.performCallCount, 0)
    }
}

// MARK: Save Instructions
extension RecipeInstructionsRepositoryImpTests {
    func test_save_shouldAppendToSavedRecipeInstructions() async throws {
        let existingInstructions = [loadMiniInstructions()]
        mockStorage.storageDictionary[expectedSavedRecipeInstructionsKey] = existingInstructions

        let newInstruction = loadMiniIcedInstructions()
        let expectedRecipeInstructions = existingInstructions + [newInstruction]

        try await sut.save(instructions: newInstruction)

        XCTAssertEqual(mockStorage.loadCalledWithKey, expectedSavedRecipeInstructionsKey)
        XCTAssertEqual(mockStorage.saveCalledWithKey, expectedSavedRecipeInstructionsKey)
        XCTAssertEqual(mockStorage.saveCalledWithValue as? [RecipeInstructions], expectedRecipeInstructions)
    }
}
