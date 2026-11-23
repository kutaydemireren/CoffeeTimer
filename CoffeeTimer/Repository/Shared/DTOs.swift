//
//  DTOs.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 12/05/2023.
//

import Foundation

struct RecipeDTO: Codable, Equatable {
    let id: String?
    let recipeProfile: RecipeProfileDTO?
    let ingredients: [IngredientDTO]?
    let brewQueue: BrewQueueDTO?
    let cupsCount: Double?
    let cupSize: Double?
}

struct RecipeProfileDTO: Codable, Equatable {
    let name: String?
    let brewMethod: BrewMethodDTO?
}

struct IngredientDTO: Codable, Equatable {
    let ingredientType: IngredientTypeDTO?
    let amount: IngredientAmountDTO?
}

enum IngredientTypeDTO: Codable, Equatable {
    case coffee
    case water
    case ice
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
    let id: String?
    let icon: String?
    let title: String?
    let path: String?
    let isIcedBrew: Bool?
    let cupsCount: CupsCountDTO?
    let ratios: [CoffeeToWaterRatioDTO]
    let info: InfoModelDTO?
    /// Optional, so methods saved before it existed (and built-in JSON) decode with `nil`.
    var referenceDose: ReferenceDoseDTO? = nil
}

struct ReferenceDoseDTO: Codable, Equatable {
    let coffee: Double?
    let water: Double?
    let ice: Double?
}

struct CupsCountDTO: Codable, Equatable {
    let minimum: Int?
    let maximum: Int?
}

struct CoffeeToWaterRatioDTO: Codable, Equatable {
    let id: String?
    let value: Double?
    let title: String?
}

struct InfoModelDTO: Codable, Equatable {
    let title: String?
    let source: String?
    let body: String?
    let animation: String?
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
    let details: String?
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
    case message
}

enum BrewStageActionMethodDTO: Codable, Equatable {
    case auto
    case userInteractive
}

enum BrewStageRequirementDTO: Codable, Equatable {
    case none
    case countdown(UInt)
}
