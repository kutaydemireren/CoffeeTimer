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
	@Published var coffeeAmount = 0.0
	@Published var waterAmount = 0.0
}
