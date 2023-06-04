//
//  CreateV60ContextToInputMapperImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateV60ContextToInputMapperImpTests: XCTestCase {

	var sut: CreateV60ContextToInputMapperImp!

	override func setUpWithError() throws {
		sut = CreateV60ContextToInputMapperImp()
	}

	func test_map_whenEmptyRecipeProfile_shouldThrowErrorMissing() throws {
		let context = CreateRecipeContext()

		XCTAssertThrowsError(try sut.map(context: context)) { error in
			XCTAssertEqual(error as? CreateRecipeMapperError, CreateRecipeMapperError.missingRecipeProfile)
		}
	}

	func test_map_shouldReturn1CupTo250MLWaterRatio() throws {
		let context = createNonEmptyProfileContext()
		context.cupsCount = 1

		let resultedInput = try sut.map(context: context)

		XCTAssertEqual(resultedInput.water, .init(amount: 250, type: .millilitre))
	}

	func test_map_shouldReturnExpectedCoffeeAmount() throws {
		let context = createNonEmptyProfileContext()
		context.cupsCount = 16
		context.ratio = .ratio16

		let resultedInput = try sut.map(context: context)

		XCTAssertEqual(resultedInput.coffee, .init(amount: 250, type: .gram))
	}

	private func createNonEmptyProfileContext() -> CreateRecipeContext {
		let context = CreateRecipeContext()
		context.recipeProfile = .stubSingleV60
		return context
	}
}
