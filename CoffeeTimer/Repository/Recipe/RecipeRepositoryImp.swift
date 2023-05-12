//
//  RecipeRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation

final class RecipeRepositoryImp: RecipeRepository {
	// TODO: Persistence
	static var selectedRecipe: Recipe = MockStore.savedRecipes.first!
	static var savedRecipes: [Recipe] = MockStore.savedRecipes

	func getSavedRecipes() -> [Recipe] {
		return Self.savedRecipes
	}

	func save(_ recipe: Recipe) {
		Self.savedRecipes.append(recipe)
	}
}
