//
//  CreateBrewMethodUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2024.
//

import XCTest
@testable import CoffeeTimer

// TODO: move
extension InstructionAction {
    func isEqual(to rhs: InstructionAction) -> Bool {
        (
            self as? PutInstructionAction == rhs as? PutInstructionAction &&
            self as? PauseInstructionAction == rhs as? PauseInstructionAction &&
            self as? MessageInstructionAction == rhs as? MessageInstructionAction

        )
    }
}

//

final class CreateBrewMethodUseCaseImpTests: XCTestCase {
    let validContext: CreateBrewMethodContext = {
        let createBrewMethodContext = CreateBrewMethodContext()
        createBrewMethodContext.methodTitle = "title"
        createBrewMethodContext.instructions = [.stubMessage]
        return createBrewMethodContext
    }()

    var mockInstructionsRepository: MockRecipeInstructionsRepository!
    var mockMethodRepository: MockBrewMethodRepository!
    var sut: CreateBrewMethodUseCaseImp!

    override func setUpWithError() throws {
        mockInstructionsRepository = MockRecipeInstructionsRepository()
        mockMethodRepository = MockBrewMethodRepository()
        sut = CreateBrewMethodUseCaseImp(
            recipeInstructionsRepository: mockInstructionsRepository,
            brewMethodRepository: mockMethodRepository
        )
    }

    override func tearDownWithError() throws {
        mockInstructionsRepository = nil
        mockMethodRepository = nil
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

    func test_create_whenInstructionsRepositoryThrows_shouldThrowExpectedError() async throws {
        mockInstructionsRepository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.create(from: validContext)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_create_shouldCallInstructionsRepositoryWithUUIDStringAsID() async throws {
        try await sut.create(from: validContext)

        let idString = mockInstructionsRepository._receivedRecipeInstructions.identifier
        XCTAssertNotNil(UUID(uuidString: idString), "ID (\(idString)) in path is not a valid UUID")
    }

    func test_create_shouldCallInstructionsRepositoryWithExpectedSteps() async throws {
        validContext.instructions = [.stubMessage, .stubPut, .stubPause]

        try await sut.create(from: validContext)

        let resultedInstructions = mockInstructionsRepository._receivedRecipeInstructions.steps
        let expectedInstructions: [RecipeInstructionStep] = [.stubMessage, .stubPut, .stubPause]
        XCTAssertEqual(expectedInstructions.count, resultedInstructions.count)
        zip(expectedInstructions, resultedInstructions).forEach { (expectedStep, resultedStep) in
            XCTAssertEqual(expectedStep.action, resultedStep.action)
            XCTAssertTrue(expectedStep.instructionAction!.isEqual(to: resultedStep.instructionAction!))
        }
    }

    func test_create_whenMethodRepositoryThrows_shouldThrowExpectedError() async throws {
        mockMethodRepository._error = TestError.notAllowed

        await assertThrowsError {
            try await sut.create(from: validContext)
        } _: { error in
            XCTAssertEqual(error as? TestError, .notAllowed)
        }
    }

    func test_create_shouldCallMethodRepositoryWithUUIDStringAsID() async throws {
        try await sut.create(from: validContext)

        let idString = mockMethodRepository._brewMethod.id
        XCTAssertNotNil(UUID(uuidString: idString), "ID (\(idString)) in path is not a valid UUID")
    }

    func test_create_shouldCallMethodRepositoryWithExpectedTitle() async throws {
        try await sut.create(from: validContext)

        XCTAssertEqual(mockMethodRepository._brewMethod.title, validContext.methodTitle)
    }

    func test_create_shouldCallMethodRepositoryWithExpectedCustomPath() async throws {
        try await sut.create(from: validContext)

        XCTAssertTrue(mockMethodRepository._brewMethod.path.hasPrefix("custom-method://"))

        let idSubstring = mockMethodRepository._brewMethod.path.replacingOccurrences(of: "custom-method://", with: "")
        XCTAssertNotNil(UUID(uuidString: idSubstring), "ID (\(idSubstring)) in path is not a valid UUID")
    }

    func test_create_whenIngredientsDoNotContainIce_shouldCallMethodRepositoryWithHotBrewAndRatios() async throws {
        try await sut.create(from: validContext)

        XCTAssertFalse(mockMethodRepository._brewMethod.isIcedBrew)
        XCTAssertEqual(mockMethodRepository._brewMethod.ratios, StaticCoffeetoWaterRatioGenerator.hotBrew())
    }

    func test_create_whenIngredientsContainIce_shouldCallMethodRepositoryWithIcedBrewAndRatios() async throws {
        validContext.instructions = [
            .stubMessage, .stubPutCoffee, .stubPutIce, .stubPause, .stubPutWater
        ]

        try await sut.create(from: validContext)

        XCTAssertTrue(mockMethodRepository._brewMethod.isIcedBrew)
        XCTAssertEqual(mockMethodRepository._brewMethod.ratios, StaticCoffeetoWaterRatioGenerator.icedBrew())
    }
}
