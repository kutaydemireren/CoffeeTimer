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
}

struct BrewQueue: Equatable {
	let stages: [BrewStage]
}

struct BrewStage: Equatable {
	let action: BrewStageAction
	let requirement: BrewStageRequirement
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
