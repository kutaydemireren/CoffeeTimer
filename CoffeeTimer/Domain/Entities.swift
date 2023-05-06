//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

struct Recipe: Equatable {
	let name: String
	let ingredients: [Ingredient]
	let brewQueue: BrewQueue
}

struct Ingredient: Equatable {
	let ingredientType: IngredientType
	let amount: IngredientAmount
}

enum IngredientType {
	case coffee
	case water
}

struct IngredientAmount: Equatable {
	let amount: UInt
	let type: IngredientAmountType
}

enum IngredientAmountType {
	case spoon
	case gram
	case millilitre
}

struct BrewQueue: Equatable {
	let stages: [BrewStage]
}

struct BrewStage: Equatable {
	// TODO: Remove and properly create each
	init(action: BrewStageAction, requirement: BrewStageRequirement, startMethod: BrewStageActionMethod? = nil) {
		self.action = action
		self.requirement = requirement
		self.startMethod = startMethod ?? .userInteractive
		self.passMethod = requirement == .none ? .userInteractive : .auto
	}

	let action: BrewStageAction
	let requirement: BrewStageRequirement
	let startMethod: BrewStageActionMethod
	let passMethod: BrewStageActionMethod
}

enum BrewStageActionMethod: Equatable {
	case auto
	case userInteractive
}

enum BrewStageAction: Equatable {
	case boil(water: IngredientAmount)
	case put(coffee: IngredientAmount)
	case pour(water: IngredientAmount)
	case wet
	case swirl
	case pause
	case finish
}

enum BrewStageRequirement: Equatable {
	case none
	case countdown(UInt)
}
