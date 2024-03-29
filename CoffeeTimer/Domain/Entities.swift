//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

enum BrewMethod: String, Equatable {
	case v60
	case v60Iced
	case chemex
	case melitta
	case frenchPress

	var title: String {
		switch self {
		case .v60:
			return "V60"
		case .v60Iced:
			return "V60 Iced"
		case .chemex:
			return "Chemex"
		case .melitta:
			return "Melitta"
		case .frenchPress:
			return "French Press"
		}
	}

	var isIced: Bool {
		switch self {
		case .v60Iced:
			return true
		default:
			return false
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
	case boilWater(IngredientAmount)
	case putCoffee(IngredientAmount)
	case putIce(IngredientAmount)
	case pourWater(IngredientAmount)
	case wet
	case swirl
	case swirlThoroughly
	case pause
	case finish
	case finishIced
}

enum BrewStageRequirement: Equatable {
	case none
	case countdown(UInt)
}
