//
//  RecipeRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation

protocol RecipeRepository: AnyObject {
	static var selectedRecipe: Recipe { get set }
	static var savedRecipes: [Recipe] { get set }

	func getSavedRecipes() -> [Recipe]
	func save(_ recipe: Recipe)
}
