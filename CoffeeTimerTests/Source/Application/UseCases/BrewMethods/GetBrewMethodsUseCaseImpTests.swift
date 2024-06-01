//
//  GetBrewMethodsUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

//

final class MockBrewMethodRepository: BrewMethodRepository {
    var _brewMethods: [BrewMethod]!
    var _error: Error!

    func fetchBrewMethods() async throws -> [BrewMethod] {
        if let _error {
            throw _error
        }

        return _brewMethods
    }
}

//

final class GetBrewMethodsUseCaseImpTests: XCTestCase {
    var mockBrewMethodRepository: MockBrewMethodRepository!
    var sut: GetBrewMethodsUseCaseImp!

    override func setUpWithError() throws {
        mockBrewMethodRepository = MockBrewMethodRepository()
        sut = GetBrewMethodsUseCaseImp(repository: mockBrewMethodRepository)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_getAll_whenErrorThrown_shouldThrowExpectedError() async throws {
        mockBrewMethodRepository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.getAll()
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }
}
