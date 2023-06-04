//
//  CreateRecipeFromContextUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateRecipeFromContextUseCaseImpTests: XCTestCase {

	var mockCreateV60SingleCupRecipeUseCase: MockCreateV60SingleCupRecipeUseCase!
	var mockCreateV60SingleCupContextToInputsMapper: MockCreateV60SingleCupContextToInputsMapper!
	var sut: CreateRecipeFromContextUseCaseImp!

    override func setUpWithError() throws {
		mockCreateV60SingleCupRecipeUseCase = MockCreateV60SingleCupRecipeUseCase()
		mockCreateV60SingleCupContextToInputsMapper = MockCreateV60SingleCupContextToInputsMapper()
		sut = CreateRecipeFromContextUseCaseImp(
			createV60SingleCupRecipeUseCase: mockCreateV60SingleCupRecipeUseCase,
			createV60SingleCupContextToInputsMapper: mockCreateV60SingleCupContextToInputsMapper
		)
    }

	func test_create_shouldCreateExpectedRecipe() {
		let expectedRecipe = Recipe.stubSingleV60
		mockCreateV60SingleCupRecipeUseCase._recipe = expectedRecipe

		let resultedRecipe = sut.create(from: CreateRecipeContext())

		XCTAssertEqual(resultedRecipe, expectedRecipe)
	}

	func test_create_shouldCreateWithExpectedInputs() {
		let expectedContext = CreateRecipeContext()
		let expectedInputs = CreateV60SingleCupRecipeInputs.stubSingleV60
		mockCreateV60SingleCupContextToInputsMapper._inputs = expectedInputs

		let _ = sut.create(from: expectedContext)

		XCTAssertEqual(mockCreateV60SingleCupContextToInputsMapper._context, expectedContext)
		XCTAssertEqual(mockCreateV60SingleCupRecipeUseCase._inputs, expectedInputs)
	}
}
