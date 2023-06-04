//
//  CreateRecipeFromContextUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class MockCreateV60IcedUseCase: CreateV60IcedRecipeUseCase {
	var _recipe: Recipe!
	var _input: CreateV60RecipeInput?

	func create(input: CreateV60RecipeInput) -> Recipe {
		self._input = input

		return _recipe
	}
}

final class CreateRecipeFromContextUseCaseImpTests: XCTestCase {

	var mockCreateV60SingleCupRecipeUseCase: MockCreateV60SingleCupRecipeUseCase!
	var mockCreateV60IcedRecipeUseCase: MockCreateV60IcedUseCase!
	var mockCreateV60ContextToInputMapper: MockCreateV60ContextToInputMapper!
	var sut: CreateRecipeFromContextUseCaseImp!

    override func setUpWithError() throws {
		mockCreateV60SingleCupRecipeUseCase = MockCreateV60SingleCupRecipeUseCase()
		mockCreateV60IcedRecipeUseCase = MockCreateV60IcedUseCase()
		mockCreateV60ContextToInputMapper = MockCreateV60ContextToInputMapper()
		sut = CreateRecipeFromContextUseCaseImp(
			createV60SingleCupRecipeUseCase: mockCreateV60SingleCupRecipeUseCase,
			createV60IcedRecipeUseCase: mockCreateV60IcedRecipeUseCase,
			CreateV60ContextToInputMapper: mockCreateV60ContextToInputMapper
		)
    }

	func test_create_whenMappingFails_shouldReturnNil() {
		let expectedContext = CreateRecipeContext()

		let resultedRecipe = sut.create(from: expectedContext)

		XCTAssertNil(resultedRecipe)
		XCTAssertEqual(mockCreateV60ContextToInputMapper._context, expectedContext)
	}

	func test_create_whenTypeIsV60AndSingleCup_shouldCreateV60SingleCupUsingExpectedInput() {
		let context = CreateRecipeContext()
		context.selectedBrewMethod = .v60
		context.cupsCount = 1

		let expectedInput = CreateV60RecipeInput.stubSingleV60
		mockCreateV60ContextToInputMapper._input = expectedInput

		mockCreateV60SingleCupRecipeUseCase._recipe = .stubMini

		let resultedRecipe = sut.create(from: context)

		XCTAssertEqual(resultedRecipe, .stubMini)
		XCTAssertEqual(mockCreateV60SingleCupRecipeUseCase._input, expectedInput)
	}

	// TODO: temporary requirement until method V60 is introduced -> shouldReturnCreateV60UsingExpectedInput
	func test_create_whenTypeIsV60ButMultipleCups_shouldReturnNil() {
		let context = CreateRecipeContext()
		context.selectedBrewMethod = .v60
		context.cupsCount = 2

		let expectedInput = CreateV60RecipeInput.stubSingleV60
		mockCreateV60ContextToInputMapper._input = expectedInput

		mockCreateV60SingleCupRecipeUseCase._recipe = .stubMini

		let resultedRecipe = sut.create(from: context)

		XCTAssertNil(resultedRecipe)
		XCTAssertNil(mockCreateV60SingleCupRecipeUseCase._input)
	}

	func test_create_whenTypeIsV60Iced_shouldCreateV60IcedUsingExpectedInput() {
		let context = CreateRecipeContext()
		context.selectedBrewMethod = .v60Iced

		let expectedInput = CreateV60RecipeInput.stubSingleV60
		mockCreateV60ContextToInputMapper._input = expectedInput

		let expectedRecipe = Recipe.stubMini
		mockCreateV60IcedRecipeUseCase._recipe = expectedRecipe

		let resultedRecipe = sut.create(from: context)

		XCTAssertEqual(resultedRecipe, expectedRecipe)
		XCTAssertEqual(mockCreateV60IcedRecipeUseCase._input, expectedInput)
	}
}
