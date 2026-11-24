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
    /// Ice share of the total liquid when the method has no reference dose with ice.
    private let defaultIceShareOfTotal = 0.4

    func map(context: CreateRecipeContext) throws -> CreateRecipeInput {
        guard context.recipeProfile.hasContent else {
            throw CreateRecipeMapperError.missingRecipeProfile
        }

        guard let ratio = context.ratio else {
            throw CreateRecipeMapperError.missingRatio
        }

        var waterAmount = calculateWaterAmount(forCupsCount: Int(context.cupsCount), withCupSize: context.cupSize)

        var iceAmount: IngredientAmount?
        if let iceShare = iceShareOfTotal(for: context.selectedBrewMethod) {
            iceAmount = calculateIceAmount(forTotalAmount: waterAmount, iceShare: iceShare)
        }

        waterAmount = IngredientAmount(amount: waterAmount.amount - (iceAmount?.amount ?? 0), type: waterAmount.type)

        return CreateRecipeInput(
            recipeProfile: context.recipeProfile,
            coffee: calculateCoffeeAmount(forWaterAmount: waterAmount, withRatio: ratio),
            water: waterAmount,
            ice: iceAmount,
            cupsCount: context.cupsCount,
            cupSize: context.cupSize
        )
    }

    /// The share of the total liquid that is ice, or `nil` for a hot brew.
    ///
    /// With a reference dose that has ice, water and ice keep the method's proportion:
    /// recipe ice = recipe water × (reference ice / reference water). Otherwise iced brews use 40% of the total.
    private func iceShareOfTotal(for brewMethod: BrewMethod?) -> Double? {
        guard let brewMethod else { return nil }

        if let iceToWater = brewMethod.referenceDose?.iceToWaterShare {
            return iceToWater / (1 + iceToWater)
        }

        return brewMethod.isIcedBrew ? defaultIceShareOfTotal : nil
    }

    private func calculateWaterAmount(forCupsCount cupsCount: Int, withCupSize cupSize: Double) -> IngredientAmount {
        return IngredientAmount(
            amount: UInt(max(0, (cupSize * Double(cupsCount)).rounded())),
            type: .millilitre
        )
    }

    private func calculateIceAmount(forTotalAmount totalAmount: IngredientAmount, iceShare: Double) -> IngredientAmount {
        let ice = UInt(max(0, (Double(totalAmount.amount) * iceShare).rounded()))
        return IngredientAmount(
            amount: min(ice, totalAmount.amount),
            type: .gram
        )
    }

    private func calculateCoffeeAmount(forWaterAmount waterAmount: IngredientAmount, withRatio ratio: CoffeeToWaterRatio) -> IngredientAmount {
        guard ratio.value > 0 else { return .zeroGram }
        return IngredientAmount(
            amount: UInt((Double(waterAmount.amount) / ratio.value).rounded()),
            type: .gram
        )
    }
}
