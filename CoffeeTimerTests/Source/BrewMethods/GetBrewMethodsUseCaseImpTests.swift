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
    var _brewMethod: BrewMethod!
    var _brewMethods: [BrewMethod]!
    var _error: Error!

    func getBrewMethods() async throws -> [BrewMethod] {
        if let _error {
            throw _error
        }

        return _brewMethods
    }

    func save(brewMethod: BrewMethod) async throws {
        _brewMethod = brewMethod

        if let _error {
            throw _error
        }
    }
}

//

final class GetBrewMethodsUseCaseImpTests: XCTestCase {
    var repository: MockBrewMethodRepository!
    var sut: GetBrewMethodsUseCaseImp!

    override func setUpWithError() throws {
        repository = MockBrewMethodRepository()
        sut = GetBrewMethodsUseCaseImp(repository: repository)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_getAll_whenErrorThrown_shouldThrowExpectedError() async throws {
        repository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.getAll()
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_getAll_shouldReturnExpectedBrewMethods() async throws {
        let expectedBrewMethods: [BrewMethod] = [.frenchPress(), .v60Iced]
        repository._brewMethods = expectedBrewMethods

        let resultedBrewMethods = try await sut.getAll()

        XCTAssertEqual(resultedBrewMethods, expectedBrewMethods)
    }
}
