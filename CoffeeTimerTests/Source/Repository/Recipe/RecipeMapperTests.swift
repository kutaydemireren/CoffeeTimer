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
    
    func test_mapToRecipeDTO_shouldIncludeRecipeID() {
        let recipeId = UUID()
        let recipe = Recipe(
            id: recipeId,
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )

        let resultedRecipeDTO = sut.mapToRecipeDTO(recipe: recipe)

        XCTAssertEqual(resultedRecipeDTO.id, recipeId.uuidString)
    }
    
    func test_mapToRecipeDTO_shouldIncludeCupsCountAndCupSize() {
        let recipe = Recipe(
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 2.0,
            cupSize: 300.0
        )

        let resultedRecipeDTO = sut.mapToRecipeDTO(recipe: recipe)

        XCTAssertEqual(resultedRecipeDTO.cupsCount, 2.0)
        XCTAssertEqual(resultedRecipeDTO.cupSize, 300.0)
    }
}

// MARK: Recipe to RecipeDTO - ID Mapping
extension RecipeMapperTests {
    func test_mapToRecipe_whenRecipeDTOHasID_shouldPreserveID() throws {
        let recipeId = UUID()
        var recipeDTO = RecipeDTO.stubMini
        recipeDTO = RecipeDTO(
            id: recipeId.uuidString,
            recipeProfile: recipeDTO.recipeProfile,
            ingredients: recipeDTO.ingredients,
            brewQueue: recipeDTO.brewQueue,
            cupsCount: recipeDTO.cupsCount,
            cupSize: recipeDTO.cupSize
        )

        let resultedRecipe = try sut.mapToRecipe(recipeDTO: recipeDTO)

        XCTAssertEqual(resultedRecipe.id, recipeId)
    }
    
    func test_mapToRecipe_whenRecipeDTONoID_shouldGenerateNewID() throws {
        var recipeDTO = RecipeDTO.stubMini
        recipeDTO = RecipeDTO(
            id: nil,
            recipeProfile: recipeDTO.recipeProfile,
            ingredients: recipeDTO.ingredients,
            brewQueue: recipeDTO.brewQueue,
            cupsCount: recipeDTO.cupsCount,
            cupSize: recipeDTO.cupSize
        )

        let resultedRecipe = try sut.mapToRecipe(recipeDTO: recipeDTO)

        XCTAssertNotNil(resultedRecipe.id)
        // Verify it's a valid UUID
        let idString = resultedRecipe.id.uuidString
        XCTAssertEqual(UUID(uuidString: idString), resultedRecipe.id)
    }
    
    func test_mapToRecipe_whenRecipeDTOHasInvalidID_shouldGenerateNewID() throws {
        var recipeDTO = RecipeDTO.stubMini
        recipeDTO = RecipeDTO(
            id: "invalid-uuid",
            recipeProfile: recipeDTO.recipeProfile,
            ingredients: recipeDTO.ingredients,
            brewQueue: recipeDTO.brewQueue,
            cupsCount: recipeDTO.cupsCount,
            cupSize: recipeDTO.cupSize
        )

        let resultedRecipe = try sut.mapToRecipe(recipeDTO: recipeDTO)

        XCTAssertNotNil(resultedRecipe.id)
        // Verify it generated a new UUID (not the invalid one)
        XCTAssertNotEqual(resultedRecipe.id.uuidString, "invalid-uuid")
    }
}
