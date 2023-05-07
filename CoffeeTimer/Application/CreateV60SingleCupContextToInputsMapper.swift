//
//  CreateV60SingleCupContextToInputsMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

protocol CreateV60SingleCupContextToInputsMapper {
	func map(context: CreateRecipeContext) -> CreateV60SingleCupRecipeInputs
}

struct CreateV60SingleCupContextToInputsMapperImp: CreateV60SingleCupContextToInputsMapper {
	private let waterAmountPerCup = IngredientAmount(amount: 250, type: .millilitre)

	func map(context: CreateRecipeContext) -> CreateV60SingleCupRecipeInputs {
		let waterAmount = calculateWaterAmount(forCupsCount: Int(context.cupsCountAmount))
		return CreateV60SingleCupRecipeInputs(
			name: context.recipeName,
			coffee: calculateCoffeeAmount(forWaterAmount: waterAmount, withRatio: context.ratio),
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
