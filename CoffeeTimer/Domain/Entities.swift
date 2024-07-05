//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

struct BrewMethod: Equatable {
    let id: String
    let title: String
    let path: String
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

struct Recipe: Equatable {
    let recipeProfile: RecipeProfile
    let ingredients: [Ingredient]
    let brewQueue: BrewQueue
}

struct RecipeProfile: Equatable {
    let name: String
    let icon: RecipeProfileIcon
    let cupsCount: Double
    let ratio: CoffeeToWaterRatio
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

    init(
        action: BrewStageAction,
        requirement: BrewStageRequirement,
        startMethod: BrewStageActionMethod,
        passMethod: BrewStageActionMethod,
        message: String = "" // TODO: process instr msg -> remove default
    ) {
        self.action = action
        self.requirement = requirement
        self.startMethod = startMethod
        self.passMethod = passMethod
        self.message = message
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
