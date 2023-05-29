//
//  Entities+Stub.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 29/05/2023.
//

import Foundation

extension Recipe {
	static var stubSingleV60: Recipe {
		return CreateV60SingleCupRecipeUseCaseImp().create(inputs: .stubSingleV60)
	}
}

extension CreateV60SingleCupRecipeInputs {
	static var stubSingleV60: CreateV60SingleCupRecipeInputs{
		return CreateV60SingleCupRecipeInputs(recipeProfile: .stubSingleV60, coffee: .init(amount: 15, type: .gram), water: .init(amount: 250, type: .millilitre))
	}
}

extension RecipeProfileIcon {
	static var stubSingleV60: RecipeProfileIcon {
		return RecipeProfileIcon(title: "rocket", color: "#800080")
	}
}

extension RecipeProfile {
	static var stubSingleV60: RecipeProfile {
		return RecipeProfile(name: "Single V60 Recipe", icon: .stubSingleV60)
	}
}

extension BrewQueue {
	static var stubSingleV60: BrewQueue {
		return Recipe.stubSingleV60.brewQueue
	}
}
