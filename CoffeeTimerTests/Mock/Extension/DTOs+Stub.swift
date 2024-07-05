//
//  DTOs+Stub.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 29/05/2023.
//

@testable import CoffeeTimer

extension BrewMethodDTO {
    static var v60Single: Self {
        return BrewMethodDTO(id: "v60-single", title: "V60 Single", path: "/v60-single", cupsCount: .v60Single, ratios: [.ratio16, .ratio18, .ratio20])
    }

    static var frenchPress: Self {
        return BrewMethodDTO(id: "french-press", title: "French Press", path: "/french-press", cupsCount: .frenchPress, ratios: [.ratio17, .ratio18, .ratio20])
    }
}

extension CupsCountDTO {
    static var v60Single: Self {
        return CupsCountDTO(minimum: 1, maximum: 1)
    }

    static var frenchPress: Self {
        return CupsCountDTO(minimum: nil, maximum: nil)
    }
}

extension CoffeeToWaterRatioDTO {
    static var ratio16: Self {
        return CoffeeToWaterRatioDTO(id: "1:16", value: 16, title: "1 - 16")
    }

    static var ratio17: Self {
        return CoffeeToWaterRatioDTO(id: "1:17", value: 17, title: "1 - 17")
    }

    static var ratio18: Self {
        return CoffeeToWaterRatioDTO(id: "1:18", value: 18, title: "1 - 18")
    }

    static var ratio20: Self {
        return CoffeeToWaterRatioDTO(id: "1:20", value: 20, title: "1 - 20")
    }
}

extension BrewQueueDTO {
    static var stubMini: BrewQueueDTO {
        BrewQueueDTO(stages: [
            .init(action: .putCoffee(.init(amount: 10, type: .gram)), requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put all your 10.0 grams of coffee to brewer"),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto, message: "To bloom, pour 40.0 millilitres of water\nTotal: 40.0 millilitres of water"),
            .init(action: .pause, requirement: .countdown(30), startMethod: .auto, passMethod: .auto, message: "Let it bloom for 30.0 seconds"),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .userInteractive, message: "To bloom, pour 40.0 millilitres of water\nTotal: 80.0 millilitres of water")
        ])
    }
}

extension RecipeDTO {
    static var stubMini: RecipeDTO {
        return RecipeDTO(
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini
        )
    }
}

extension RecipeDTO {
    var excludingProfile: Self {
        return RecipeDTO(
            recipeProfile: nil,
            ingredients: ingredients,
            brewQueue: brewQueue
        )
    }

    var excludingProfileIcon: Self {
        return RecipeDTO(
            recipeProfile: .init(name: nil, icon: nil, cupsCount: 0, ratio: ""),
            ingredients: ingredients,
            brewQueue: brewQueue
        )
    }

    var excludingCupsCount: Self {
        return RecipeDTO(
            recipeProfile: .init(name: nil, icon: .stubMini, cupsCount: nil, ratio: ""),
            ingredients: ingredients,
            brewQueue: brewQueue
        )
    }

    var excludingRatio: Self {
        return RecipeDTO(
            recipeProfile: .init(name: nil, icon: .stubMini, cupsCount: 0, ratio: nil),
            ingredients: ingredients,
            brewQueue: brewQueue
        )
    }

    var excludingIngredientType: Self {
        return RecipeDTO(
            recipeProfile: recipeProfile,
            ingredients: [
                .init(ingredientType: nil, amount: ingredients?.first!.amount)
            ],
            brewQueue: brewQueue
        )
    }

    var excludingIngredientAmount: Self {
        return RecipeDTO(
            recipeProfile: recipeProfile,
            ingredients: [
                .init(ingredientType: ingredients?.first!.ingredientType, amount: nil)
            ],
            brewQueue: brewQueue
        )
    }

    var excludingIngredientAmountType: Self {
        return RecipeDTO(
            recipeProfile: recipeProfile,
            ingredients: [
                .init(ingredientType: ingredients?.first!.ingredientType, amount: .init(amount: nil, type: nil))
            ],
            brewQueue: brewQueue
        )
    }

    var excludingBrewQueue: Self {
        return RecipeDTO(
            recipeProfile: recipeProfile,
            ingredients: ingredients,
            brewQueue: nil
        )
    }

    var excludingBrewStageAction: Self {
        return RecipeDTO(
            recipeProfile: recipeProfile,
            ingredients: ingredients,
            brewQueue: .init(stages: [
                .init(action: nil, requirement: nil, startMethod: nil, passMethod: nil)
            ])
        )
    }

    var excludingBrewStageRequirement: Self {
        return RecipeDTO(
            recipeProfile: recipeProfile,
            ingredients: ingredients,
            brewQueue: .init(stages: [
                .init(action: .pause, requirement: nil, startMethod: nil, passMethod: nil)
            ])
        )
    }
}

extension RecipeProfileDTO {
    static var stubMini: RecipeProfileDTO {
        return RecipeProfileDTO(
            name: "My Recipe Mini",
            icon: .stubMini,
            cupsCount: 1,
            ratio: "1:16"
        )
    }
}

extension RecipeProfileIconDTO {
    static var stubMini: RecipeProfileIconDTO {
        return RecipeProfileIconDTO(title: "rocket-mini", colorHex: "#200020", imageName: "recipe-profile-rocket-mini")
    }
}

extension Array where Element == IngredientDTO {
    static var stubMini: [IngredientDTO] {
        return [
            .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
            .init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
        ]
    }
}
