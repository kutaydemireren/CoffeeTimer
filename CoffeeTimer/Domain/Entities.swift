//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

struct Recipe {
	let id: UUID
	let name: String
	let ingredients: [Ingredient]
	let brewQueue: BrewQueue
}

struct Ingredient {
	let id: String
	let name: String
	let amount: IngredientAmount
}

struct IngredientAmount {
	let id: String
	let type: String
	let amount: Int
}

struct BrewQueue {
	let id: UUID
	let stages: [BrewStage]
}

struct BrewStage {
	let id: UUID
	let header: String
	let title: String
	let timeIntervalLeft: TimeInterval
}
