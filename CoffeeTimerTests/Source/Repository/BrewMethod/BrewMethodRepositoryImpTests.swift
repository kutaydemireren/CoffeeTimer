//
//  BrewMethodRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

final class BrewMethodRepositoryImpTests: XCTestCase {
    var mockNetworkManager: MockNetworkManager!
    var sut: BrewMethodRepositoryImp!

    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        sut = BrewMethodRepositoryImp(networkManager: mockNetworkManager)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_fetchBrewMethods_whenNetworkThrowsError_shouldThrowExpectedError() async throws {
        mockNetworkManager._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetchBrewMethods()
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }
}
