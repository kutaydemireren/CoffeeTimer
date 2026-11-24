//
//  CreateRecipeFromInputUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 31/05/2024.
//

import XCTest
@testable import CoffeeTimer

final class CreateRecipeFromInputUseCaseImpTests: XCTestCase {
    var sut: CreateRecipeFromInputUseCaseImp!

    override func setUp() {
        sut = CreateRecipeFromInputUseCaseImp()
    }

    override func tearDown() {
        sut = nil
    }

    func test_create_shouldRecipeHasExpectedRecipeProfile() {
        let resultedRecipe = sut.create(from: .stubSingleV60, instructions: .empty)

        XCTAssertEqual(resultedRecipe.recipeProfile, .stubSingleV60)
    }

    func test_create_shouldRecipeHasExpectedIngredients() {
        let expectedIngredients: [Ingredient] = .stubSingleV60

        let resultedRecipe = sut.create(
            from: .init(
                recipeProfile: .empty,
                coffee: expectedIngredients[0].amount,
                water: expectedIngredients[1].amount, 
                ice: nil,
                cupsCount: 1.0,
                cupSize: 250.0
            ),
            instructions: .empty
        )

        XCTAssertEqual(resultedRecipe.ingredients, expectedIngredients)
    }

    func test_create_whenWithIce_shouldRecipeHasExpectedIngredients() {
        let expectedIngredients: [Ingredient] = .stubMiniIced

        let resultedRecipe = sut.create(
            from: .init(
                recipeProfile: .empty,
                coffee: expectedIngredients[0].amount,
                water: expectedIngredients[1].amount,
                ice: expectedIngredients[2].amount,
                cupsCount: 1.0,
                cupSize: 250.0
            ),
            instructions: .empty
        )

        XCTAssertEqual(resultedRecipe.ingredients, expectedIngredients)
    }

    func test_create_shouldRecipeHasExpectedBrewQueue() {
        let ingredients: [Ingredient] = .stubMini

        let resultedRecipe = sut.create(
            from: CreateRecipeInput(
                recipeProfile: .empty,
                coffee: ingredients[0].amount,
                water: ingredients[1].amount, 
                ice: nil,
                cupsCount: 1.0,
                cupSize: 250.0
            ),
            instructions: loadMiniInstructions()
        )

        XCTAssertEqual(resultedRecipe.brewQueue, .stubMini)
    }

    func test_create_iced_shouldRecipeHasExpectedBrewQueue() {
        let ingredients: [Ingredient] = .stubMiniIced

        let resultedRecipe = sut.create(
            from: CreateRecipeInput(
                recipeProfile: .empty,
                coffee: ingredients[0].amount,
                water: ingredients[1].amount, 
                ice: ingredients[2].amount,
                cupsCount: 1.0,
                cupSize: 250.0
            ),
            instructions: loadMiniIcedInstructions()
        )

        XCTAssertEqual(resultedRecipe.brewQueue, .stubMiniIced)
    }

    func test_create_whenStepAmountHasFraction_shouldRoundToNearestGram() {
        let pourFifth = PutInstructionAction(
            requirement: nil, startMethod: .auto, skipMethod: .userInteractive,
            message: "Pour #current.amount ml", details: nil,
            ingredient: .water,
            amount: .init(type: .millilitre, mainFactor: .init(factor: 0.2, factorOf: "water"), adjustmentFactor: nil)
        )
        let pourUpToSixtyPercent = PutInstructionAction(
            requirement: nil, startMethod: .auto, skipMethod: .userInteractive,
            message: "Pour #current.amount ml", details: nil,
            ingredient: .water,
            amount: .init(
                type: .millilitre,
                mainFactor: .init(factor: 0.6, factorOf: "water"),
                adjustmentFactor: .init(factor: -1, factorOf: "#current.water")
            )
        )
        let pourRest = PutInstructionAction(
            requirement: nil, startMethod: .auto, skipMethod: .userInteractive,
            message: "Pour #current.amount ml", details: nil,
            ingredient: .water,
            amount: .init(type: .millilitre, mainFactor: .init(factor: 1, factorOf: "#remaining.water"), adjustmentFactor: nil)
        )
        let instructions = RecipeInstructions(
            identifier: "rounding",
            steps: [
                .init(action: .put, instructionAction: pourFifth),
                .init(action: .put, instructionAction: pourUpToSixtyPercent),
                .init(action: .put, instructionAction: pourRest)
            ]
        )

        let resultedRecipe = sut.create(
            from: CreateRecipeInput(
                recipeProfile: .empty,
                coffee: .init(amount: 14, type: .gram),
                water: .init(amount: 233, type: .millilitre),
                ice: nil,
                cupsCount: 1.0,
                cupSize: 233.0
            ),
            instructions: instructions
        )

        // 0.2 × 233 = 46.6 → 47 (was 46); 0.6 × 233 − 47 = 92.8 → 93; the rest 233 − 140 = 93.
        XCTAssertEqual(resultedRecipe.brewQueue.stages.map(\.action), [
            .pourWater(.init(amount: 47, type: .millilitre)),
            .pourWater(.init(amount: 93, type: .millilitre)),
            .pourWater(.init(amount: 93, type: .millilitre))
        ])
    }
}
