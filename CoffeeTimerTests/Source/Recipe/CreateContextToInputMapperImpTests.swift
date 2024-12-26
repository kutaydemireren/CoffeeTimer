//
//  CreateContextToInputMapperImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class CreateContextToInputMapperImpTests: XCTestCase {

    var sut: CreateContextToInputMapperImp!

    override func setUpWithError() throws {
        sut = CreateContextToInputMapperImp()
    }

    func test_map_whenRecipeProfileEmpty_shouldThrowErrorMissing() throws {
        let context = createValidContext()
        context.recipeProfile = .empty

        XCTAssertThrowsError(try sut.map(context: context)) { error in
            XCTAssertEqual(error as? CreateRecipeMapperError, CreateRecipeMapperError.missingRecipeProfile)
        }
    }

    func test_map_whenNonEmptyRecipeProfile_shouldReturnExpectedProfile() throws {
        let context = createValidContext()
        let expectedRecipeProfile = RecipeProfile.stubMini
        context.recipeProfile = expectedRecipeProfile

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.recipeProfile, expectedRecipeProfile)
    }

    func test_map_whenRatioNil_shouldThrowErrorMissing() throws {
        let context = createValidContext()
        context.ratio = nil

        XCTAssertThrowsError(try sut.map(context: context)) { error in
            XCTAssertEqual(error as? CreateRecipeMapperError, CreateRecipeMapperError.missingRatio)
        }
    }

    func test_map_when1CupWithCupSizeOf300_shouldReturn300mlWater() throws {
        let context = createValidContext()
        context.cupsCount = 1
        context.cupSize = 300

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.water, .init(amount: 300, type: .millilitre))
        XCTAssertEqual(resultedInput.ice, nil)
    }

    func test_map_when1CupWithIce_shouldReturn150mlWaterAnd100gIce() throws {
        let context = createValidContext()
        context.selectedBrewMethod = .v60Iced
        context.cupsCount = 1

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.water, .init(amount: 150, type: .millilitre))
        XCTAssertEqual(resultedInput.ice, .init(amount: 100, type: .gram))
    }

    func test_map_shouldReturnExpectedCoffeeAmount() throws {
        let context = createValidContext()
        context.cupsCount = 16
        context.ratio = .ratio16

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.coffee, .init(amount: 250, type: .gram))
    }

    private func createValidContext() -> CreateRecipeContext {
        let context = CreateRecipeContext()
        context.recipeProfile = .stubSingleV60
        context.ratio = .ratio16
        return context
    }
}
