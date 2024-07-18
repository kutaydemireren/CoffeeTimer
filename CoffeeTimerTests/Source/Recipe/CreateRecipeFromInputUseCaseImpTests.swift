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
                ice: nil
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
                ice: expectedIngredients[2].amount
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
                ice: nil
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
                ice: ingredients[2].amount
            ),
            instructions: loadMiniIcedInstructions()
        )

        XCTAssertEqual(resultedRecipe.brewQueue, .stubMiniIced)
    }
}
