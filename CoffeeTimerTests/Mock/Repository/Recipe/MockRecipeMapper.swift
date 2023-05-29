//
//  MockRecipeMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 30/05/2023.
//

@testable import CoffeeTimer

final class MockRecipeMapper: RecipeMapper {
	var mapToRecipeCalled = false
	var mapToRecipeReceivedRecipeDTO: RecipeDTO?

	var recipesDict: [Int: Recipe] = [:]
	var recipeDTOsDict: [Int: RecipeDTO] = [:]

	var mapToRecipeDTOCalled = false
	var mapToRecipeDTOReceivedRecipe: Recipe?

	func mapToRecipe(recipeDTO: RecipeDTO) -> Recipe {
		mapToRecipeCalled = true
		mapToRecipeReceivedRecipeDTO = recipeDTO

		let firstMatchingIndex = recipeDTOsDict.filter { (_, value) in
			return value == recipeDTO
		}.keys.first!

		return recipesDict[firstMatchingIndex] ?? .stubSingleV60
	}

	func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO {
		mapToRecipeDTOCalled = true
		mapToRecipeDTOReceivedRecipe = recipe

		let firstMatchingIndex = recipesDict.filter { (_, value) in
			return value == recipe

		}.keys.first!

		return recipeDTOsDict[firstMatchingIndex] ?? .stub
	}
}
