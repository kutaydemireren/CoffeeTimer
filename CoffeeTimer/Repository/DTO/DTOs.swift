//
//  DTOs.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 12/05/2023.
//

import Foundation

struct RecipeDTO: Codable {
	let recipeProfile: RecipeProfileDTO?
	let ingredients: [IngredientDTO]?
	let brewQueue: BrewQueueDTO?
}

struct RecipeProfileDTO: Codable {
	let name: String?
	let icon: RecipeProfileIconDTO?
}

struct RecipeProfileIconDTO: Codable {
	let title: String?
	let colorHex: String?
	let imageName: String?
}

struct IngredientDTO: Codable {
	let ingredientType: IngredientTypeDTO?
	let amount: IngredientAmountDTO?
}

enum IngredientTypeDTO: Codable {
	case coffee
	case water
}

struct IngredientAmountDTO: Codable {
	let amount: UInt?
	let type: IngredientAmountTypeDTO?
}

enum IngredientAmountTypeDTO: Codable {
	case spoon
	case gram
	case millilitre
}

struct BrewQueueDTO: Codable {
	let stages: [BrewStageDTO]?
}

struct BrewStageDTO: Codable {
	let action: BrewStageActionDTO?
	let requirement: BrewStageRequirementDTO?
	let startMethod: BrewStageActionMethodDTO?
	let passMethod: BrewStageActionMethodDTO?
}

enum BrewStageActionDTO: Codable {
	case boil(water: IngredientAmountDTO)
	case put(coffee: IngredientAmountDTO)
	case pour(water: IngredientAmountDTO)
	case wet
	case swirl
	case pause
	case finish
}

enum BrewStageActionMethodDTO: Codable {
	case auto
	case userInteractive
}

enum BrewStageRequirementDTO: Codable {
	case none
	case countdown(UInt)
}
