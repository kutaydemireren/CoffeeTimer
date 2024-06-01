//
//  RecipeInstructionsRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

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

final class RecipeInstructionsRepositoryImpTests: XCTestCase {
    var mockNetworkManager: MockNetworkManager!
    var sut: RecipeInstructionsRepositoryImp!

    override func setUp() {
        mockNetworkManager = MockNetworkManager()
        sut = RecipeInstructionsRepositoryImp(networkManager: mockNetworkManager)
    }

    override func tearDown() {
        mockNetworkManager = nil
        sut = nil
    }

    func test_fetchInstructions_whenNetworkThrowsError_shouldThrowExpectedError() {
        mockNetworkManager._error = TestError.notAllowed

        XCTAssertThrowsError(try sut.fetchInstructions(for: .frenchPress)) { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchInstructions_shouldReturnEmpty() {
        mockNetworkManager._data = Data()

        XCTAssertEqual(try sut.fetchInstructions(for: .frenchPress), .empty)
    }
}
