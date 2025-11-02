//
//  ConfigureContextFromRecipeUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/10/2025.
//

import XCTest
@testable import CoffeeTimer

final class ConfigureContextFromRecipeUseCaseImpTests: XCTestCase {
    var sut: ConfigureContextFromRecipeUseCaseImp!
    var context: CreateRecipeContext!
    
    override func setUpWithError() throws {
        sut = ConfigureContextFromRecipeUseCaseImp()
        context = CreateRecipeContext()
    }
}

// MARK: - Configure Recipe Profile
extension ConfigureContextFromRecipeUseCaseImpTests {
    func test_configure_shouldSetRecipeProfile() {
        let recipe = Recipe.stubMini
        let ratios = [CoffeeToWaterRatio.ratio16, .ratio17, .ratio18]
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.recipeProfile, recipe.recipeProfile)
        XCTAssertEqual(context.selectedBrewMethod, recipe.recipeProfile.brewMethod)
    }
}

// MARK: - Configure Ratio
extension ConfigureContextFromRecipeUseCaseImpTests {
    func test_configure_whenRecipeHasWaterAndCoffee_shouldCalculateClosestRatio() {
        let recipe = Recipe.stubMini
        let ratios = [CoffeeToWaterRatio.ratio16, .ratio17, .ratio18]
        // Recipe has 200ml water and 10g coffee = 20:1 ratio, closest to ratio18 (18:1, difference of 2)
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.ratio, .ratio18)
    }
    
    func test_configure_whenCalculatedRatioIsBetweenTwoRatios_shouldSelectClosest() {
        let recipe = Recipe(
            recipeProfile: .stubMini,
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 170, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        let ratios = [CoffeeToWaterRatio.ratio16, .ratio17, .ratio18]
        // 170ml / 10g = 17:1 ratio, should match ratio17 exactly
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.ratio, .ratio17)
    }
    
    func test_configure_whenCoffeeAmountIsZero_shouldSetFirstRatio() {
        let recipe = Recipe(
            recipeProfile: .stubMini,
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 0, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        let ratios = [CoffeeToWaterRatio.ratio16, .ratio17]
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.ratio, .ratio16)
    }
    
    func test_configure_whenNoCoffeeIngredient_shouldSetFirstRatio() {
        let recipe = Recipe(
            recipeProfile: .stubMini,
            ingredients: [
                .init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
        let ratios = [CoffeeToWaterRatio.ratio17, .ratio18]
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.ratio, .ratio17)
    }
}

// MARK: - Configure Cups Count and Cup Size
extension ConfigureContextFromRecipeUseCaseImpTests {
    func test_configure_whenRecipeHasCupsCountAndCupSize_shouldUsePersistedValues() {
        let recipe = Recipe(
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 2.0,
            cupSize: 300.0
        )
        let ratios = [CoffeeToWaterRatio.ratio16]
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.cupsCount, 2.0)
        XCTAssertEqual(context.cupSize, 300.0)
    }
    
    func test_configure_whenRecipeMissingCupsCountAndCupSize_shouldCalculateFromIngredients() {
        let recipe = Recipe(
            recipeProfile: .stubMini,
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 400, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 0.0,
            cupSize: 0.0
        )
        let ratios = [CoffeeToWaterRatio.ratio16]
        // Total liquid = 400ml, cupsCount minimum = 1, so cupSize = 400 / 1 = 400
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.cupsCount, 1.0)
        XCTAssertEqual(context.cupSize, 400.0)
    }
    
    func test_configure_whenRecipeMissingCupsCountAndCupSizeForIcedBrew_shouldIncludeIceInCalculation() {
        let icedBrewMethod = BrewMethod(
            id: "v60-iced",
            iconName: "v60",
            title: "V60 Iced",
            path: "/v60-iced",
            isIcedBrew: true,
            cupsCount: .unlimited,
            ratios: [.ratio16],
            info: .empty
        )
        let recipe = Recipe(
            recipeProfile: RecipeProfile(
                name: "Iced Recipe",
                brewMethod: icedBrewMethod
            ),
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 120, type: .millilitre)),
                .init(ingredientType: .ice, amount: .init(amount: 80, type: .gram))
            ],
            brewQueue: .stubMini,
            cupsCount: 0.0,
            cupSize: 0.0
        )
        let ratios = [CoffeeToWaterRatio.ratio16]
        // Total liquid = 120ml water + 80g ice = 200ml, cupsCount = 1, cupSize = 200
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.cupsCount, 1.0)
        XCTAssertEqual(context.cupSize, 200.0)
    }
    
    func test_configure_whenRecipeHasMinimumCupsCountGreaterThanOne_shouldUseMinimum() {
        let brewMethod = BrewMethod(
            id: "test",
            iconName: "test",
            title: "Test",
            path: "/test",
            isIcedBrew: false,
            cupsCount: CupsCount(minimum: 2, maximum: 4),
            ratios: [.ratio16],
            info: .empty
        )
        let recipe = Recipe(
            recipeProfile: RecipeProfile(
                name: "Test Recipe",
                brewMethod: brewMethod
            ),
            ingredients: [
                .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
                .init(ingredientType: .water, amount: .init(amount: 400, type: .millilitre))
            ],
            brewQueue: .stubMini,
            cupsCount: 0.0,
            cupSize: 0.0
        )
        let ratios = [CoffeeToWaterRatio.ratio16]
        // Total liquid = 400ml, minimum cupsCount = 2, so cupSize = 400 / 2 = 200
        
        sut.configure(context: context, from: recipe, with: ratios)
        
        XCTAssertEqual(context.cupsCount, 2.0)
        XCTAssertEqual(context.cupSize, 200.0)
    }
}

