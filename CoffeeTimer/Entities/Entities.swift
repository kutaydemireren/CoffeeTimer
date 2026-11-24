//
//  Entities.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/03/2023.
//

import Foundation

struct BrewMethod: Equatable, Hashable, Identifiable, Titled {
    let id: String
    let iconName: String
    let title: String
    let path: String
    let isIcedBrew: Bool
    let cupsCount: CupsCount
    let ratios: [CoffeeToWaterRatio]
    let info: InfoModel
    /// The dose a custom method was written for. `nil` for built-in methods and for methods saved before it existed.
    var referenceDose: ReferenceDose? = nil
}

/// Amounts, in grams, that a method was written for (for example 30 g coffee and 500 g water).
struct ReferenceDose: Equatable, Hashable {
    let coffee: Double
    let water: Double
    let ice: Double?

    init(coffee: Double, water: Double, ice: Double? = nil) {
        self.coffee = coffee
        self.water = water
        self.ice = ice
    }

    /// Water divided by coffee, for example 16.7 for 30 g coffee and 500 g water. `nil` when either amount is not positive.
    var ratioValue: Double? {
        guard coffee > 0, water > 0 else { return nil }
        return water / coffee
    }

    /// Ice divided by water. `nil` when the method adds no ice.
    var iceToWaterShare: Double? {
        guard let ice, ice > 0, water > 0 else { return nil }
        return ice / water
    }
}

struct CupsCount: Equatable, Hashable {
    let minimum: Int
    let maximum: Int?

    static var unlimited: CupsCount {
        return CupsCount(minimum: 1, maximum: nil)
    }
}

struct CoffeeToWaterRatio: Equatable, Hashable, Identifiable, Titled {
    let id: String
    let value: Double
    let title: String
}

extension CoffeeToWaterRatio {
    /// "1:16" for whole values, "1:16.7" otherwise (one decimal).
    static func label(for value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return "1:\(Int(rounded))"
        }
        return "1:\(String(format: "%.1f", rounded))"
    }

    /// The ratio a method was written for, listed first when creating a recipe from it.
    static func methodOwn(value: Double) -> CoffeeToWaterRatio {
        let rounded = (value * 10).rounded() / 10
        let label = label(for: rounded)
        return CoffeeToWaterRatio(id: label, value: rounded, title: "\(label) - As written")
    }
}

extension BrewMethod {
    /// The method's own ratio, from its reference dose. `nil` when it has none.
    var ownRatio: CoffeeToWaterRatio? {
        guard let value = referenceDose?.ratioValue else { return nil }
        return .methodOwn(value: value)
    }

    /// Ratios offered when creating a recipe: the method's own ratio first (if any), then `ratios` without a duplicate of it.
    var recipeRatios: [CoffeeToWaterRatio] {
        guard let ownRatio else { return ratios }
        return [ownRatio] + ratios.filter { abs($0.value - ownRatio.value) > 0.0001 }
    }

    /// The ratio selected by default when creating a recipe. `nil` keeps today's behaviour (nothing selected).
    var defaultRatio: CoffeeToWaterRatio? {
        ownRatio
    }
}

struct InfoModel: Equatable, Hashable {
    let title: String
    let source: String?
    let body: String
    let animation: String?

    init(title: String, source: String? = nil, body: String, animation: String? = nil) {
        self.title = title
        self.source = source
        self.body = body
        self.animation = animation
    }
}

struct Recipe: Equatable, Identifiable {
    let id: UUID
    let recipeProfile: RecipeProfile
    let ingredients: [Ingredient]
    let brewQueue: BrewQueue
    let cupsCount: Double
    let cupSize: Double

    init(
        id: UUID = UUID(),
        recipeProfile: RecipeProfile,
        ingredients: [Ingredient],
        brewQueue: BrewQueue,
        cupsCount: Double,
        cupSize: Double
    ) {
        self.id = id
        self.recipeProfile = recipeProfile
        self.ingredients = ingredients
        self.brewQueue = brewQueue
        self.cupsCount = cupsCount
        self.cupSize = cupSize
    }

    static func ==(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.recipeProfile == rhs.recipeProfile && lhs.ingredients == rhs.ingredients && lhs.brewQueue == rhs.brewQueue && lhs.cupsCount == rhs.cupsCount && lhs.cupSize == rhs.cupSize
    }
}

struct RecipeProfile: Equatable {
    let name: String
    let brewMethod: BrewMethod
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
