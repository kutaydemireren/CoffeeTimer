//
//  CreateContextToInputMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

enum CreateRecipeMapperError: Error {
    case missingRecipeProfile
    case missingRatio
}

// TODO: rename to drop v60
protocol CreateContextToInputMapper {
    func map(context: CreateRecipeContext) throws -> CreateRecipeInput
}

struct CreateContextToInputMapperImp: CreateContextToInputMapper {
    private let waterAmountPerCup = IngredientAmount(amount: 250, type: .millilitre)

    func map(context: CreateRecipeContext) throws -> CreateRecipeInput {
        guard context.recipeProfile.hasContent else {
            throw CreateRecipeMapperError.missingRecipeProfile
        }

        guard let ratio = context.ratio else {
            throw CreateRecipeMapperError.missingRatio
        }

        let waterAmount = calculateWaterAmount(forCupsCount: Int(context.cupsCount))
        return CreateRecipeInput(
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
