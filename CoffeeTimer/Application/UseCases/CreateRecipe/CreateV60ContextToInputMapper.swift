//
//  CreateV60ContextToInputMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

enum CreateRecipeMapperError: Error {
	case missingRecipeProfile
	case missingRatio
}

protocol CreateV60ContextToInputMapper {
	func map(context: CreateRecipeContext) throws -> CreateV60RecipeInput
}

struct CreateV60ContextToInputMapperImp: CreateV60ContextToInputMapper {
	private let waterAmountPerCup = IngredientAmount(amount: 250, type: .millilitre)

	func map(context: CreateRecipeContext) throws -> CreateV60RecipeInput {
		guard context.recipeProfile.hasContent else {
			throw CreateRecipeMapperError.missingRecipeProfile
		}

		guard let ratio = context.ratio else {
			throw CreateRecipeMapperError.missingRatio
		}

		let waterAmount = calculateWaterAmount(forCupsCount: Int(context.cupsCount))
		return CreateV60RecipeInput(
			recipeProfile: context.recipeProfile,
			coffee: calculateCoffeeAmount(forWaterAmount: waterAmount, withRatio: ratio),
			water: waterAmount
		)
	}

	private func calculateWaterAmount(forCupsCount cupsCount: Int) -> IngredientAmount {
		return IngredientAmount(
			amount: waterAmountPerCup.amount * UInt(cupsCount),
			type: waterAmountPerCup.type
		)
	}

	private func calculateCoffeeAmount(forWaterAmount waterAmount: IngredientAmount, withRatio ratio: CoffeeToWaterRatio) -> IngredientAmount {
		return IngredientAmount(
			amount: waterAmount.amount / UInt(ratio.value),
			type: .gram
		)
	}
}
