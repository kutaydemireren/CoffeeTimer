//
//  CreateRecipeContext.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/05/2023.
//

import Foundation

// TODO: Move
extension RecipeProfile {
	static var empty: RecipeProfile {
		RecipeProfile(name: "", icon: .init(title: "", color: .clear))
	}

	var isEmpty: Bool {
		return self == .empty
	}
}

final class CreateRecipeContext: ObservableObject {
	@Published var selectedBrewMethod: BrewMethod?
	@Published var recipeProfile: RecipeProfile = .empty
	@Published var cupsCountAmount: Double = 0.0
	@Published var ratio: CoffeeToWaterRatio = .ratio16
}
