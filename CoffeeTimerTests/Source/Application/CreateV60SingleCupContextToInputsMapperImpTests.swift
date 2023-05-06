//
//  CreateV60SingleCupContextToInputsMapperImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateV60SingleCupContextToInputsMapperImpTests: XCTestCase {

	var sut: CreateV60SingleCupContextToInputsMapperImp!

	override func setUpWithError() throws {
		sut = CreateV60SingleCupContextToInputsMapperImp()
	}

	func test_map_shouldReturn1CupTo250MLWaterRatio() {
		let context = CreateRecipeContext()
		context.cupsCountAmount = 1

		let resultedInputs = sut.map(context: context)

		XCTAssertEqual(resultedInputs.water, .init(amount: 250, type: .millilitre))
	}

	func test_map_shouldReturnExpectedCoffeeAmount() {
		let context = CreateRecipeContext()
		context.cupsCountAmount = 16
		context.ratio = .ratio16

		let resultedInputs = sut.map(context: context)

		XCTAssertEqual(resultedInputs.coffee, .init(amount: 250, type: .gram))
	}
}
