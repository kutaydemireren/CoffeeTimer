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

protocol Storage {
	func save<T: Codable>(_ value: T?, forKey key: String)
	func load<T: Codable>(forKey key: String) -> T?
}

// TODO: Move

protocol RecipeMapperProtocol {
	func mapToRecipe(recipeDTO: RecipeDTO) -> Recipe
	func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO
}

struct RecipeMapper: RecipeMapperProtocol {
	func mapToRecipe(recipeDTO: RecipeDTO) -> Recipe {
		// Perform mapping from RecipeDTO to Recipe
		// Return the mapped Recipe object
	}

	func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO {
		// Perform mapping from Recipe to RecipeDTO
		// Return the mapped RecipeDTO object
	}
}

struct StorageImp: Storage {

	var userDefaults: UserDefaults

	init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}

	func save<T>(_ value: T?, forKey key: String) {
		userDefaults.set(value, forKey: key)
	}

	func load<T>(forKey key: String) -> T? {
		return userDefaults.object(forKey: key) as? T
	}
}

final class RecipeRepositoryImp: RecipeRepository {
	private let selectedRecipeKey = RecipeConstants.selectedRecipeKey
	private let savedRecipesKey = RecipeConstants.savedRecipesKey

	private var storage: Storage
	private var mapper: RecipeMapperProtocol

	init(
		storage: Storage = StorageImp(userDefaults: .standard),
		mapper: RecipeMapperProtocol = RecipeMapper()
	) {
		self.storage = storage
		self.mapper = mapper
	}
}

extension RecipeRepositoryImp {
	func getSelectedRecipe() -> Recipe? {
		if let recipeDTO = storage.load(forKey: selectedRecipeKey) as RecipeDTO? {
			return mapper.mapToRecipe(recipeDTO: recipeDTO)
		}
		return nil
	}

	func update(selectedRecipe: Recipe) {
		let recipeDTO = mapper.mapToRecipeDTO(recipe: selectedRecipe)
		storage.save(recipeDTO, forKey: selectedRecipeKey)
	}
}

extension RecipeRepositoryImp {
	func getSavedRecipes() -> [Recipe] {
		let recipeDTOs = getSavedRecipeDTOs()
		return recipeDTOs.map { mapper.mapToRecipe(recipeDTO: $0) }
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
