//
//  DTOs.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 12/05/2023.
//

import Foundation

struct RecipeDTO: Codable, Equatable {
    let recipeProfile: RecipeProfileDTO?
    let ingredients: [IngredientDTO]?
    let brewQueue: BrewQueueDTO?
}

struct RecipeProfileDTO: Codable, Equatable {
    let name: String?
    let icon: RecipeProfileIconDTO?
    let cupsCount: Double?
    let ratio: String?
}

struct RecipeProfileIconDTO: Codable, Equatable {
    let title: String?
    let colorHex: String?
    let imageName: String?
}

struct IngredientDTO: Codable, Equatable {
    let ingredientType: IngredientTypeDTO?
    let amount: IngredientAmountDTO?
}

enum IngredientTypeDTO: Codable, Equatable {
    case coffee
    case water
}

struct IngredientAmountDTO: Codable, Equatable {
    let amount: UInt?
    let type: IngredientAmountTypeDTO?
}

enum IngredientAmountTypeDTO: String, Codable, Equatable {
    case gram
    case millilitre
}

struct BrewMethodDTO: Codable, Equatable {
    let id: String
    let title: String
    let path: String
    let ratios: [CoffeeToWaterRatioDTO]
}

struct CoffeeToWaterRatioDTO: Codable, Equatable {
    let id: String
    let value: Double
    let title: String
}

struct BrewQueueDTO: Codable, Equatable {
    let stages: [BrewStageDTO]?
}

struct BrewStageDTO: Codable, Equatable {
    let action: BrewStageActionDTO?
    let requirement: BrewStageRequirementDTO?
    let startMethod: BrewStageActionMethodDTO?
    let passMethod: BrewStageActionMethodDTO?
    let message: String?
    
    init(
        action: BrewStageActionDTO?,
        requirement: BrewStageRequirementDTO?,
        startMethod: BrewStageActionMethodDTO?,
        passMethod: BrewStageActionMethodDTO?,
        message: String? = ""
    ) {
        self.action = action
        self.requirement = requirement
        self.startMethod = startMethod
        self.passMethod = passMethod
        self.message = message
    }
}

enum BrewStageActionDTO: Codable, Equatable {
    case boilWater(IngredientAmountDTO)
    case putCoffee(IngredientAmountDTO)
    case putIce(IngredientAmountDTO)
    case pourWater(IngredientAmountDTO)
    case wet
    case swirl
    case swirlThoroughly
    case pause
    case finish
    case finishIced
}

enum BrewStageActionMethodDTO: Codable, Equatable {
    case auto
    case userInteractive
}

enum BrewStageRequirementDTO: Codable, Equatable {
    case none
    case countdown(UInt)
}
