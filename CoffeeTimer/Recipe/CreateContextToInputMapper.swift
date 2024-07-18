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

protocol CreateContextToInputMapper {
    func map(context: CreateRecipeContext) throws -> CreateRecipeInput
}

struct CreateContextToInputMapperImp: CreateContextToInputMapper {
    private let waterAmountPerCup = IngredientAmount(amount: 250, type: .millilitre)
    private let iceToWaterRatio = 0.4

    func map(context: CreateRecipeContext) throws -> CreateRecipeInput {
        guard context.recipeProfile.hasContent else {
            throw CreateRecipeMapperError.missingRecipeProfile
        }

        guard let ratio = context.ratio else {
            throw CreateRecipeMapperError.missingRatio
        }

        var waterAmount = calculateWaterAmount(forCupsCount: Int(context.cupsCount))

        var iceAmount: IngredientAmount?
        if context.selectedBrewMethod?.isIcedBrew == true {
            iceAmount = calculateIceAmount(forWaterAmount: waterAmount)
        }

        waterAmount = IngredientAmount(amount: waterAmount.amount - (iceAmount?.amount ?? 0), type: waterAmount.type)

        return CreateRecipeInput(
            recipeProfile: context.recipeProfile,
            coffee: calculateCoffeeAmount(forWaterAmount: waterAmount, withRatio: ratio),
            water: waterAmount,
            ice: iceAmount
        )
    }

    private func calculateWaterAmount(forCupsCount cupsCount: Int) -> IngredientAmount {
        return IngredientAmount(
            amount: waterAmountPerCup.amount * UInt(cupsCount),
            type: waterAmountPerCup.type
        )
    }

    private func calculateIceAmount(forWaterAmount waterAmount: IngredientAmount) -> IngredientAmount {
        return IngredientAmount(
            amount: UInt(Double(waterAmount.amount) * iceToWaterRatio),
            type: .gram
        )
    }

    private func calculateCoffeeAmount(forWaterAmount waterAmount: IngredientAmount, withRatio ratio: CoffeeToWaterRatio) -> IngredientAmount {
        return IngredientAmount(
            amount: waterAmount.amount / UInt(ratio.value),
            type: .gram
        )
    }
}
