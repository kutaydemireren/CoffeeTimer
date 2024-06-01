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
    var mockNetworkManager: MockNetworkManager!
    var mockDecoding: MockDecoding!
    var sut: RecipeInstructionsRepositoryImp!

    override func setUp() {
        mockNetworkManager = MockNetworkManager()
        mockNetworkManager._data = Data()
        mockDecoding = MockDecoding()
        mockDecoding._decoded = RecipeInstructions.empty
        sut = RecipeInstructionsRepositoryImp(networkManager: mockNetworkManager, decoding: mockDecoding)
    }

    override func tearDown() {
        mockNetworkManager = nil
        mockDecoding = nil
        sut = nil
    }

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

    func test_fetchInstructions_shouldUseExpectedBrewRequest() async throws {
        _ = try await sut.fetchInstructions(for: .frenchPress)

        XCTAssertEqual(try mockNetworkManager._request.createURLRequest(), try BrewRequest(brewMethod: .frenchPress).createURLRequest())
    }

    func test_fetchInstructions_shouldReturnExpectedRecipeInstructions() async throws {
        mockNetworkManager._data = Data()
        let expectedInstructions = loadV60SingleRecipeInstructions()
        mockDecoding._decoded = expectedInstructions

        let resultedInstructions = try await sut.fetchInstructions(for: .frenchPress)

        XCTAssertEqual(resultedInstructions, expectedInstructions)
    }
}
