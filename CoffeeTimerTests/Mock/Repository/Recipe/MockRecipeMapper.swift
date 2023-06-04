//
//  MockRecipeMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 30/05/2023.
//

@testable import CoffeeTimer

final class MockRecipeMapper: RecipeMapper {
	var mapToRecipeReceivedRecipeDTO: RecipeDTO?

	var recipesDict: [Int: Recipe] = [:]
	var recipeDTOsDict: [Int: RecipeDTO] = [:]

	var mapToRecipeDTOReceivedRecipe: Recipe?

	func mapToRecipe(recipeDTO: RecipeDTO) throws -> Recipe {
		mapToRecipeReceivedRecipeDTO = recipeDTO

		let firstMatchingIndex = recipeDTOsDict.filter { (_, value) in
			return value == recipeDTO
		}.keys.first

		guard let firstMatchingIndex = firstMatchingIndex else {
			throw RecipeMapperError.missingBrewQueue
		}

		return recipesDict[firstMatchingIndex]!
	}

	func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO {
		mapToRecipeDTOReceivedRecipe = recipe

		let firstMatchingIndex = recipesDict.filter { (_, value) in
			return value == recipe

		}.keys.first!

		return recipeDTOsDict[firstMatchingIndex]!
	}
}
