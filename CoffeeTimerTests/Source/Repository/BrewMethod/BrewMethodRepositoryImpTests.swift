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
    var mockDecoding: MockDecoding!
    var sut: BrewMethodRepositoryImp!

    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        mockNetworkManager._data = Data()
        mockDecoding = MockDecoding()
        mockDecoding._decoded = [BrewMethod]()
        sut = BrewMethodRepositoryImp(networkManager: mockNetworkManager, decoding: mockDecoding)
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

    func test_fetchBrewMethods_whenDecodingThrowsError_shouldThrowExpectedError() async throws {
        mockDecoding._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.fetchBrewMethods()
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_fetchBrewMethods_shouldReturnExpectedBrewMethods() async throws {
        mockDecoding._decoded = [BrewMethodDTO.frenchPress, BrewMethodDTO.v60Single]

        let resultedBrewMethods = try await sut.fetchBrewMethods()

        XCTAssertEqual(resultedBrewMethods, [.frenchPress, .v60Single])
    }
}
