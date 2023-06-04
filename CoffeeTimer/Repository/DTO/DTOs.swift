//
//  DTOs.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 12/05/2023.
//

import Foundation

struct RecipeDTO: Codable, Equatable {
	let recipeProfile: RecipeProfileDTO?
	let ingredients: [IngredientDTO]?
	let brewQueue: BrewQueueDTO?
}

struct RecipeProfileDTO: Codable, Equatable {
	let name: String?
	let icon: RecipeProfileIconDTO?
}

struct RecipeProfileIconDTO: Codable, Equatable {
	let title: String?
	let colorHex: String?
	let imageName: String?
}

struct IngredientDTO: Codable, Equatable {
	let ingredientType: IngredientTypeDTO?
	let amount: IngredientAmountDTO?
}

enum IngredientTypeDTO: Codable, Equatable {
	case coffee
	case water
}

struct IngredientAmountDTO: Codable, Equatable {
	let amount: UInt?
	let type: IngredientAmountTypeDTO?
}

enum IngredientAmountTypeDTO: Codable, Equatable {
	case spoon
	case gram
	case millilitre
}

struct BrewQueueDTO: Codable, Equatable {
	let stages: [BrewStageDTO]?
}

struct BrewStageDTO: Codable, Equatable {
	let action: BrewStageActionDTO?
	let requirement: BrewStageRequirementDTO?
	let startMethod: BrewStageActionMethodDTO?
	let passMethod: BrewStageActionMethodDTO?
}

enum BrewStageActionDTO: Codable, Equatable {
	case boilWater(IngredientAmountDTO)
	case putCoffee(IngredientAmountDTO)
	case pourWater(IngredientAmountDTO)
	case wet
	case swirl
	case pause
	case finish
}

enum BrewStageActionMethodDTO: Codable, Equatable {
	case auto
	case userInteractive
}

enum BrewStageRequirementDTO: Codable, Equatable {
	case none
	case countdown(UInt)
}
