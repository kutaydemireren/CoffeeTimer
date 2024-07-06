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

        XCTAssertEqual(resultedRecipe, expectedRecipe)
    }

    func test_mapToRecipe_whenRecipeProfileDTOIsNil_shouldThrowMissingProfileError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingProfile)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingRecipeProfile)
        }
    }

    func test_mapToRecipe_whenRecipeProfileIconDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingProfileIcon)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingRecipeProfileIcon)
        }
    }

    func test_mapToRecipe_whenIngredientTypeDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingIngredientType)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingIngredientType)
        }
    }

    func test_mapToRecipe_whenIngredientAmountDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingIngredientAmount)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingIngredientAmount)
        }
    }

    func test_mapToRecipe_whenIngredientAmountTypeDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingIngredientAmountType)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingIngredientAmountType)
        }
    }

    func test_mapToRecipe_whenBrewQueueDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewQueue)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewQueue)
        }
    }

    func test_mapToRecipe_whenBrewStageActionDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewStageAction)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewStageAction)
        }
    }

    func test_mapToRecipe_whenBrewStageRequirementDTOIsNil_shouldThrowMissingProfileIconError() throws {
        XCTAssertThrowsError(try sut.mapToRecipe(recipeDTO: .stubMini.excludingBrewStageRequirement)) { error in
            XCTAssertEqual(error as? RecipeMapperError, RecipeMapperError.missingBrewStageRequirement)
        }
    }
}

// MARK: RecipeDTO to Recipe
extension RecipeMapperTests {
    func test_mapToRecipeDTO_shouldMapAsExpected() {
        let recipe = Recipe.stubMini
        let expectedRecipeDTO = RecipeDTO.stubMini

        let resultedRecipeDTO = sut.mapToRecipeDTO(recipe: recipe)

        XCTAssertEqual(resultedRecipeDTO, expectedRecipeDTO)
    }
}
