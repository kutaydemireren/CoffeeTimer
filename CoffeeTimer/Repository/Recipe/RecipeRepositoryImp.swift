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
	func save<T>(_ value: T?, forKey key: String)
	func load<T>(forKey key: String) -> T?
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

	init(storage: Storage = StorageImp(userDefaults: .standard)) {
		self.storage = storage
	}

	func getSelectedRecipe() -> Recipe? {
		return storage.load(forKey: selectedRecipeKey)
	}

	func getSavedRecipes() -> [Recipe] {
		return storage.load(forKey: savedRecipesKey) ?? []
	}

	func save(_ recipe: Recipe) {
		var newRecipes = getSavedRecipes()
		newRecipes.append(recipe)
		storage.save(newRecipes, forKey: savedRecipesKey)
	}

	func update(selectedRecipe: Recipe) {
		storage.save(selectedRecipe, forKey: selectedRecipeKey)
	}
}
