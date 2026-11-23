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

    func test_map_whenDecimalRatio_shouldRoundCoffeeToNearestGram() throws {
        let context = createValidContext()
        context.cupsCount = 2
        context.cupSize = 250
        context.ratio = .methodOwn(value: 500.0 / 30.0)

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.coffee, .init(amount: 30, type: .gram))
    }

    func test_map_whenRatio18And500Water_shouldRoundCoffeeUpTo28() throws {
        let context = createValidContext()
        context.cupsCount = 2
        context.cupSize = 250
        context.ratio = .ratio18

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.coffee, .init(amount: 28, type: .gram))
    }

    func test_map_whenRatio17And250Water_shouldRoundCoffeeDownTo15() throws {
        let context = createValidContext()
        context.cupsCount = 1
        context.cupSize = 250
        context.ratio = .ratio17

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.coffee, .init(amount: 15, type: .gram))
    }

    func test_map_whenReferenceDoseWithIce_shouldKeepMethodIceShare() throws {
        let context = createValidContext()
        context.selectedBrewMethod = methodWithReferenceDose(.init(coffee: 20, water: 200, ice: 50))
        context.cupsCount = 2
        context.cupSize = 250

        let resultedInput = try sut.map(context: context)

        // 500 g total split as 200:50 → 400 g water, 100 g ice.
        XCTAssertEqual(resultedInput.water, .init(amount: 400, type: .millilitre))
        XCTAssertEqual(resultedInput.ice, .init(amount: 100, type: .gram))
    }

    func test_map_whenReferenceDoseWithIce_shouldScaleIceWithWater() throws {
        let context = createValidContext()
        context.selectedBrewMethod = methodWithReferenceDose(.init(coffee: 15, water: 150, ice: 100))
        context.cupsCount = 3
        context.cupSize = 200

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.water, .init(amount: 360, type: .millilitre))
        XCTAssertEqual(resultedInput.ice, .init(amount: 240, type: .gram))
    }

    func test_map_whenReferenceDoseWithoutIce_shouldReturnNoIce() throws {
        let context = createValidContext()
        context.selectedBrewMethod = methodWithReferenceDose(.init(coffee: 30, water: 500))
        context.cupsCount = 1

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.water, .init(amount: 250, type: .millilitre))
        XCTAssertNil(resultedInput.ice)
    }

    func test_map_whenIcedWithoutReferenceDose_shouldKeepFortyPercentIce() throws {
        let context = createValidContext()
        context.selectedBrewMethod = .v60Iced
        context.cupsCount = 2
        context.cupSize = 250

        let resultedInput = try sut.map(context: context)

        XCTAssertEqual(resultedInput.water, .init(amount: 300, type: .millilitre))
        XCTAssertEqual(resultedInput.ice, .init(amount: 200, type: .gram))
    }

    private func methodWithReferenceDose(_ referenceDose: ReferenceDose) -> BrewMethod {
        BrewMethod(
            id: "custom",
            iconName: "recipe-profile-gooseneck-kettle",
            title: "Custom",
            path: CustomMethodPathGenerator.generate(id: "custom"),
            isIcedBrew: referenceDose.ice != nil,
            cupsCount: .unlimited,
            ratios: StaticCoffeetoWaterRatioGenerator.hotBrew(),
            info: .init(title: "Custom", body: ""),
            referenceDose: referenceDose
        )
    }

    private func createValidContext() -> CreateRecipeContext {
        let context = CreateRecipeContext()
        context.recipeProfile = .stubSingleV60
        context.ratio = .ratio16
        return context
    }
}
