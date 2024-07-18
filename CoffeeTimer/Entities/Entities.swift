//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

struct BrewMethod: Equatable, Identifiable {
    let id: String
    let title: String
    let path: String
    let isIcedBrew: Bool
    let cupsCount: CupsCount
    let ratios: [CoffeeToWaterRatio]
}

struct CoffeeToWaterRatio: Equatable, Hashable, Identifiable {
    let id: String
    let value: Double
    let title: String
}

struct CupsCount: Equatable {
    let minimum: Int
    let maximum: Int?

    static var unlimited: CupsCount {
        return CupsCount(minimum: 1, maximum: nil)
    }
}

struct Recipe: Equatable, Identifiable {
    let id = UUID()
    let recipeProfile: RecipeProfile
    let ingredients: [Ingredient]
    let brewQueue: BrewQueue

    static func ==(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.recipeProfile == rhs.recipeProfile && lhs.ingredients == rhs.ingredients && lhs.brewQueue == rhs.brewQueue
    }
}

struct RecipeProfile: Equatable {
    let name: String
}

struct Ingredient: Equatable {
    let ingredientType: IngredientType
    let amount: IngredientAmount
}

enum IngredientType {
    case coffee
    case water
    case ice
}

struct IngredientAmount: Equatable {
    let amount: UInt
    let type: IngredientAmountType
}

enum IngredientAmountType {
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
    let message: String
    let details: String?
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
    case message
}

enum BrewStageRequirement: Equatable {
    case none
    case countdown(UInt)
}
