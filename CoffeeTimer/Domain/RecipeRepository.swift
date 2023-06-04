//
//  RecipeRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation

protocol RecipeRepository: AnyObject {
	func getSelectedRecipe() -> Recipe?
	func getSavedRecipes() -> [Recipe]
	func save(_ recipe: Recipe)
	func update(selectedRecipe: Recipe)
	func remove(recipe: Recipe)
}
