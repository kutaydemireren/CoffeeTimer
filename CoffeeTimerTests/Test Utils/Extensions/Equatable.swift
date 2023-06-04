//
//  Equatable.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

extension CreateV60RecipeInput: Equatable {
	public static func == (lhs: CreateV60RecipeInput, rhs: CreateV60RecipeInput) -> Bool {
		lhs.water == rhs.water &&
		lhs.coffee == rhs.coffee &&
		lhs.recipeProfile == rhs.recipeProfile
	}
}

extension CreateRecipeContext: Equatable {
	public static func == (lhs: CreateRecipeContext, rhs: CreateRecipeContext) -> Bool {
		lhs.recipeProfile == rhs.recipeProfile
	}
}
