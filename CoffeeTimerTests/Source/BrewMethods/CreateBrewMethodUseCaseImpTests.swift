//
//  CreateBrewMethodUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2024.
//

import XCTest
@testable import CoffeeTimer

final class CreateBrewMethodUseCaseImpTests: XCTestCase {
    let validContext: CreateBrewMethodContext = {
        let createBrewMethodContext = CreateBrewMethodContext()
        createBrewMethodContext.methodTitle = "title"
        createBrewMethodContext.instructions = [.stubMessage]
        return createBrewMethodContext
    }()

    var mockRepository: MockBrewMethodRepository!
    var sut: CreateBrewMethodUseCaseImp!

    override func setUpWithError() throws {
        mockRepository = MockBrewMethodRepository()
        sut = CreateBrewMethodUseCaseImp(repository: mockRepository)
    }

    override func tearDownWithError() throws {
        mockRepository = nil
        sut = nil
    }

    func test_canCreate_whenMethodTitleIsNil_shouldThrowMissingMethodTitle() {
        let createBrewMethodContext = CreateBrewMethodContext()

        XCTAssertThrowsError(try sut.canCreate(from: createBrewMethodContext)) { error in
            XCTAssertEqual(error as? CreateBrewMethodUseCaseError, .missingMethodTitle)
        }
    }

    func test_canCreate_whenInstructionsIsEmpty_shouldThrowMissingInstructions() {
        let createBrewMethodContext = CreateBrewMethodContext()
        createBrewMethodContext.methodTitle = "title"

        XCTAssertThrowsError(try sut.canCreate(from: createBrewMethodContext)) { error in
            XCTAssertEqual(error as? CreateBrewMethodUseCaseError, .missingInstructions)
        }
    }

    func test_canCreate_whenContextValid_shouldReturnTrue() throws {
        let createBrewMethodContext = CreateBrewMethodContext()
        createBrewMethodContext.methodTitle = "title"
        createBrewMethodContext.instructions = [.stubMessage]

        let resultedCanCreate = try sut.canCreate(from: createBrewMethodContext)

        XCTAssertTrue(resultedCanCreate)
    }

    func test_create_whenRepositoryThrows_shouldThrowExpectedError() async throws {
        mockRepository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.create(from: validContext)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_create_shouldCallRepositoryWithUUIDStringAsID() async throws {
        try await sut.create(from: validContext)

        XCTAssertNotNil(UUID(uuidString: mockRepository._brewMethod.id))
    }

    func test_create_shouldCallRepositoryWithExpectedTitle() async throws {
        try await sut.create(from: validContext)

        XCTAssertEqual(mockRepository._brewMethod.title, validContext.methodTitle)
    }

    func test_create_shouldCallRepositoryWithEmptyPath() async throws {
        try await sut.create(from: validContext)

        XCTAssertTrue(mockRepository._brewMethod.path.isEmpty)
    }

    func test_create_whenDefault_shouldCallRepositoryWithNotIcedBrew() async throws {
        try await sut.create(from: validContext)

        XCTAssertFalse(mockRepository._brewMethod.isIcedBrew)
    }

    func test_create_whenIngredientsIncludeIce_shouldCallRepositoryWithIcedBrew() async throws {
        validContext.instructions = [
            .stubMessage, .stubPutCoffee, .stubPutIce, .stubPause, .stubPutWater
        ]

        try await sut.create(from: validContext)

        XCTAssertTrue(mockRepository._brewMethod.isIcedBrew)
    }
}
