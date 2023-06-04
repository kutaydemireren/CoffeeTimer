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
	var mockCreateV60ContextToInputMapper: MockCreateV60ContextToInputMapper!
	var sut: CreateRecipeFromContextUseCaseImp!

    override func setUpWithError() throws {
		mockCreateV60SingleCupRecipeUseCase = MockCreateV60SingleCupRecipeUseCase()
		mockCreateV60ContextToInputMapper = MockCreateV60ContextToInputMapper()
		sut = CreateRecipeFromContextUseCaseImp(
			createV60SingleCupRecipeUseCase: mockCreateV60SingleCupRecipeUseCase,
			CreateV60ContextToInputMapper: mockCreateV60ContextToInputMapper
		)
    }

	func test_create_shouldCreateExpectedRecipe() {
		let expectedRecipe = Recipe.stubSingleV60
		mockCreateV60SingleCupRecipeUseCase._recipe = expectedRecipe

		let resultedRecipe = sut.create(from: CreateRecipeContext())

		XCTAssertEqual(resultedRecipe, expectedRecipe)
	}

	func test_create_shouldCreateWithExpectedInput() {
		let expectedContext = CreateRecipeContext()
		let expectedInput = CreateV60RecipeInput.stubSingleV60
		mockCreateV60ContextToInputMapper._input = expectedInput

		let _ = sut.create(from: expectedContext)

		XCTAssertEqual(mockCreateV60ContextToInputMapper._context, expectedContext)
		XCTAssertEqual(mockCreateV60SingleCupRecipeUseCase._input, expectedInput)
	}
}
