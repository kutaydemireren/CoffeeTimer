//
//  Equatable.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

extension CreateRecipeContext: Equatable {
	public static func == (lhs: CoffeeTimer.CreateRecipeContext, rhs: CoffeeTimer.CreateRecipeContext) -> Bool {
		lhs.cupsCountAmount == rhs.cupsCountAmount &&
		lhs.ratio == rhs.ratio &&
		lhs.selectedBrewMethod == rhs.selectedBrewMethod &&
		lhs.recipeName == rhs.recipeName
	}
}

extension CreateV60SingleCupRecipeInputs: Equatable {
	public static func == (lhs: CreateV60SingleCupRecipeInputs, rhs: CreateV60SingleCupRecipeInputs) -> Bool {
		lhs.water == rhs.water &&
		lhs.coffee == rhs.coffee &&
		lhs.name == rhs.name
	}
}
