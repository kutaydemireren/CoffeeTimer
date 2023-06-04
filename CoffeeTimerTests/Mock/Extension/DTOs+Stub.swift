//
//  DTOs+Stub.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 29/05/2023.
//

@testable import CoffeeTimer

extension BrewQueueDTO {
	static var stubMini: BrewQueueDTO {
		BrewQueueDTO(stages: [
			.init(action: .wet, requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive),
			.init(action: .boilWater(.init(amount: 10, type: .gram)), requirement: .countdown(3), startMethod: .auto, passMethod: .userInteractive),
			.init(action: .finish, requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive)
		])
	}
}

extension RecipeDTO {
	static var stubMini: RecipeDTO {
		return RecipeDTO(
			recipeProfile: .stubMini,
			ingredients: .stubMini,
			brewQueue: .stubMini
		)
	}
}

extension RecipeDTO {
	var excludingProfile: Self {
		return RecipeDTO(
			recipeProfile: nil,
			ingredients: ingredients,
			brewQueue: brewQueue
		)
	}

	var excludingProfileIcon: Self {
		return RecipeDTO(
			recipeProfile: .init(name: nil, icon: nil),
			ingredients: ingredients,
			brewQueue: brewQueue
		)
	}

	var excludingIngredientType: Self {
		return RecipeDTO(
			recipeProfile: recipeProfile,
			ingredients: [
				.init(ingredientType: nil, amount: ingredients?.first!.amount)
			],
			brewQueue: brewQueue
		)
	}

	var excludingIngredientAmount: Self {
		return RecipeDTO(
			recipeProfile: recipeProfile,
			ingredients: [
				.init(ingredientType: ingredients?.first!.ingredientType, amount: nil)
			],
			brewQueue: brewQueue
		)
	}

	var excludingIngredientAmountType: Self {
		return RecipeDTO(
			recipeProfile: recipeProfile,
			ingredients: [
				.init(ingredientType: ingredients?.first!.ingredientType, amount: .init(amount: nil, type: nil))
			],
			brewQueue: brewQueue
		)
	}

	var excludingBrewQueue: Self {
		return RecipeDTO(
			recipeProfile: recipeProfile,
			ingredients: ingredients,
			brewQueue: nil
		)
	}

	var excludingBrewStageAction: Self {
		return RecipeDTO(
			recipeProfile: recipeProfile,
			ingredients: ingredients,
			brewQueue: .init(stages: [
				.init(action: nil, requirement: nil, startMethod: nil, passMethod: nil)
			])
		)
	}

	var excludingBrewStageRequirement: Self {
		return RecipeDTO(
			recipeProfile: recipeProfile,
			ingredients: ingredients,
			brewQueue: .init(stages: [
				.init(action: .pause, requirement: nil, startMethod: nil, passMethod: nil)
			])
		)
	}
}

extension RecipeProfileDTO {
	static var stubMini: RecipeProfileDTO {
		return RecipeProfileDTO(name: "My Recipe Mini", icon: .stubMini)
	}
}

extension RecipeProfileIconDTO {
	static var stubMini: RecipeProfileIconDTO {
		return RecipeProfileIconDTO(title: "rocket-mini", colorHex: "#200020", imageName: "recipe-profile-rocket-mini")
	}
}

extension Array where Element == IngredientDTO {
	static var stubMini: [IngredientDTO] {
		return [
			.init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
			.init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
		]
	}
}
