//
//  BrewQueue+Stub.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/04/2023.
//

import Foundation

extension BrewQueue {
	static var stubMini: BrewQueue {
		BrewQueue(stages: [
			.init(action: .wet, requirement: .none),
			.init(action: .boil(water: .init(amount: 10, type: .gram)), requirement: .countdown(3)),
			.init(action: .finish, requirement: .none)
		])
	}

	static var stubSingleV60: BrewQueue {
		return Recipe.stubSingleV60.brewQueue
	}
}

// TODO: Move
extension Recipe {
	static var stubMini: Recipe {
		return Recipe(
			recipeProfile: .stubMini,
			ingredients: .stubMini,
			brewQueue: .stubMini
		)
	}

	static var stubSingleV60: Recipe {
		return CreateV60SingleCupRecipeUseCaseImp().create(inputs: .stubSingleV60)
	}
}

extension CreateV60SingleCupRecipeInputs {
	static var stubSingleV60: CreateV60SingleCupRecipeInputs{
		return CreateV60SingleCupRecipeInputs(recipeProfile: .stubSingleV60, coffee: .init(amount: 15, type: .gram), water: .init(amount: 250, type: .millilitre))
	}
}

extension RecipeProfile {
	static var stubMini: RecipeProfile {
		return RecipeProfile(name: "My Recipe Mini", icon: .stubMini)
	}

	static var stubSingleV60: RecipeProfile {
		return RecipeProfile(name: "Single V60 Recipe", icon: .stubSingleV60)
	}
}

extension RecipeProfileIcon {
	static var stubMini: RecipeProfileIcon {
		return RecipeProfileIcon(title: "rocket-mini", color: "#200020")
	}

	static var stubSingleV60: RecipeProfileIcon {
		return RecipeProfileIcon(title: "rocket", color: "#800080")
	}
}

extension Array where Element == Ingredient {
	static var stubMini: [Ingredient] {
		return [
			Ingredient(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
			Ingredient(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
		]
	}
}

//

extension BrewQueueDTO {
	static var stubMini: BrewQueueDTO {
		BrewQueueDTO(stages: [
			.init(action: .wet, requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .none),
			.init(action: .boil(water: .init(amount: 10, type: .gram)), requirement: .countdown(3), startMethod: .userInteractive, passMethod: .none),
			.init(action: .finish, requirement: BrewStageRequirementDTO.none, startMethod: .none, passMethod: .userInteractive)
		])
	}
}

// TODO: Move
extension RecipeDTO {
	static var stubMini: RecipeDTO {
		return RecipeDTO(
			recipeProfile: .stubMini,
			ingredients: .stubMini,
			brewQueue: .stubMini
		)
	}
}

// TODO: Move
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
		return RecipeProfileIconDTO(title: "rocket-mini", colorHex: "#200020", imageName: nil)
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
