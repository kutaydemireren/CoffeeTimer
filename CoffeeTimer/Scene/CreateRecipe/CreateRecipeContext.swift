//
//  CreateRecipeContext.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/05/2023.
//

import Foundation

final class CreateRecipeContext: ObservableObject {
	@Published var selectedBrewMethod: BrewMethod?
	@Published var recipeName: String = ""
	@Published var selectedRecipeProfile: RecipeProfile?
	@Published var cupsCountAmount = 0.0
	@Published var ratio: CoffeeToWaterRatio = .ratio16
}
