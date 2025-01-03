//
//  RecipeMapperTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 21/05/2023.
//

import XCTest
@testable import CoffeeTimer

extension RecipeDTO {
}

final class RecipeMapperTests: XCTestCase {
    var sut: RecipeMapperImp!

    override func setUpWithError() throws {
        sut = RecipeMapperImp()
    }
}

// MARK: Recipe to RecipeDTO
extension RecipeMapperTests {
    func test_mapToRecipe_shouldMapAsExpected() throws {
        let expectedRecipe = Recipe.stubMini

        let resultedRecipe = try sut.mapToRecipe(recipeDTO: .stubMini)

        XCTAssertEqual(resultedRecipe.recipeProfile, expectedRecipe.recipeProfile)
        XCTAssertEqual(resultedRecipe.ingredients, expectedRecipe.ingredients)
        XCTAssertEqual(resultedRecipe.brewQueue, expectedRecipe.brewQueue)
    }

    func test_mapToRecipe_whenIcedRecipe_shouldMapAsExpected() {
        let expectedRecipe = RecipeDTO.stubMiniIced

        let resultedRecipe = sut.mapToRecipeDTO(recipe: .stubMiniIced)

        XCTAssertEqual(resultedRecipe.recipeProfile, expectedRecipe.recipeProfile)
        XCTAssertEqual(resultedRecipe.ingredients, expectedRecipe.ingredients)
        XCTAssertEqual(resultedRecipe.brewQueue, expectedRecipe.brewQueue)
    }

    func test_mapToRecipe_whenRecipeProfileDTOIsNil_shouldThrowMissingProfileError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingProfile)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingRecipeProfile)
        }
    }

    func test_mapToRecipe_whenProfileNameIsNil_shouldThrowMissingProfileName() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingProfileName)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingProfileName)
        }
    }

    func test_mapToRecipe_whenBrewMethodIsNil_shouldThrowMissingBrewMethod() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewMethod)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewMethod)
        }
    }

    func test_mapToRecipe_whenIngredientTypeDTOIsNil_shouldThrowMissingIngredientTypeError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingIngredientType)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingIngredientType)
        }
    }

    func test_mapToRecipe_whenIngredientAmountDTOIsNil_shouldThrowMissingIngredientAmountError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingIngredientAmount)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingIngredientAmount)
        }
    }

    func test_mapToRecipe_whenIngredientAmountTypeDTOIsNil_shouldThrowMissingIngredientAmountTypeError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingIngredientAmountType)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingIngredientAmountType)
        }
    }

    func test_mapToRecipe_whenBrewQueueDTOIsNil_shouldThrowMissingBrewQueueError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewQueue)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewQueue)
        }
    }

    func test_mapToRecipe_whenBrewStageActionDTOIsNil_shouldThrowMissingBrewStageActionError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewStageAction)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewStageAction)
        }
    }

    func test_mapToRecipe_whenBrewStageRequirementDTOIsNil_shouldThrowMissingBrewStageRequirementError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewStageRequirement)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewStageRequirement)
        }
    }
}

// MARK: RecipeDTO to Recipe
extension RecipeMapperTests {
    func test_mapToRecipeDTO_shouldMapAsExpected() {
        let expectedRecipeDTO = RecipeDTO.stubMini

        let resultedRecipeDTO = sut.mapToRecipeDTO(recipe: .stubMini)

        XCTAssertEqual(resultedRecipeDTO.recipeProfile, expectedRecipeDTO.recipeProfile)
        XCTAssertEqual(resultedRecipeDTO.ingredients, expectedRecipeDTO.ingredients)
        XCTAssertEqual(resultedRecipeDTO.brewQueue, expectedRecipeDTO.brewQueue)
    }

    func test_mapToRecipeDTO_whenIcedRecipe_shouldMapAsExpected() {
        let expectedRecipeDTO = RecipeDTO.stubMiniIced

        let resultedRecipeDTO = sut.mapToRecipeDTO(recipe: .stubMiniIced)

        XCTAssertEqual(resultedRecipeDTO.recipeProfile, expectedRecipeDTO.recipeProfile)
        XCTAssertEqual(resultedRecipeDTO.ingredients, expectedRecipeDTO.ingredients)
        XCTAssertEqual(resultedRecipeDTO.brewQueue, expectedRecipeDTO.brewQueue)
    }
}
