//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

enum BrewMethod: String, Equatable {
	case v60
	case chemex
	case melitta
	case frenchPress

	var title: String {
		switch self {
		case .v60:
			return "V60"
		case .chemex:
			return "Chemex"
		case .melitta:
			return "Melitta"
		case .frenchPress:
			return "French Press"
		}
	}
}

struct Recipe: Equatable {
	let recipeProfile: RecipeProfile
	let ingredients: [Ingredient]
	let brewQueue: BrewQueue
}
struct RecipeProfile: Equatable {
	let name: String
	let icon: RecipeProfileIcon
}

struct RecipeProfileIcon: Equatable {
	let title: String
	let color: String
	let imageName: String

	init(title: String, color: String) {
		self.title = title
		self.color = color
		self.imageName = "recipe-profile-\(title.split(separator: " ").first ?? "")"
	}
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
	let action: BrewStageAction
	let requirement: BrewStageRequirement
	let startMethod: BrewStageActionMethod
	let passMethod: BrewStageActionMethod

	init(
		action: BrewStageAction,
		requirement: BrewStageRequirement,
		startMethod: BrewStageActionMethod,
		passMethod: BrewStageActionMethod
	) {
		self.action = action
		self.requirement = requirement
		self.startMethod = startMethod
		self.passMethod = passMethod
	}
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
