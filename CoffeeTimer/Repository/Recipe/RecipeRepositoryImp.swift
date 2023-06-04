//
//  RecipeRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation

struct RecipeConstants {
	static let selectedRecipeKey = "selectedRecipe"
	static let savedRecipesKey = "savedRecipes"
}

final class RecipeRepositoryImp: RecipeRepository {
	private let selectedRecipeKey = RecipeConstants.selectedRecipeKey
	private let savedRecipesKey = RecipeConstants.savedRecipesKey

	private var storage: Storage
	private var mapper: RecipeMapper

	init(
		storage: Storage = StorageImp(userDefaults: .standard),
		mapper: RecipeMapper = RecipeMapperImp()
	) {
		self.storage = storage
		self.mapper = mapper
	}
}

// MARK: Selected Recipe
extension RecipeRepositoryImp {
	func getSelectedRecipe() -> Recipe? {
		guard let recipeDTO = storage.load(forKey: selectedRecipeKey) as RecipeDTO? else {
			return nil
		}

		return try? mapper.mapToRecipe(recipeDTO: recipeDTO)
	}

	func update(selectedRecipe: Recipe) {
		let recipeDTO = mapper.mapToRecipeDTO(recipe: selectedRecipe)
		storage.save(recipeDTO, forKey: selectedRecipeKey)
	}
}

// MARK: Save(d) Recipe(s)
extension RecipeRepositoryImp {
	func getSavedRecipes() -> [Recipe] {
		let recipeDTOs = getSavedRecipeDTOs()
		return recipeDTOs.compactMap { try? mapper.mapToRecipe(recipeDTO: $0) }
	}

	func save(_ recipe: Recipe) {
		var newRecipeDTOs = getSavedRecipeDTOs()
		newRecipeDTOs.append(mapper.mapToRecipeDTO(recipe: recipe))
		storage.save(newRecipeDTOs, forKey: savedRecipesKey)
	}

	private func getSavedRecipeDTOs() -> [RecipeDTO] {
		if let recipeDTO = storage.load(forKey: savedRecipesKey) as [RecipeDTO]? {
			return recipeDTO
		}
		return []
	}
}

// MARK: Remove
extension RecipeRepositoryImp {
	func remove(recipe: Recipe) {
		
	}
}
