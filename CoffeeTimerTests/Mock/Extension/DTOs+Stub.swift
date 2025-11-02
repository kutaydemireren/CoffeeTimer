//
//  DTOs+Stub.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 29/05/2023.
//

@testable import CoffeeTimer

extension BrewMethodDTO {
    static var v60Single: Self {
        return BrewMethodDTO(
            id: "v60-single",
            icon: "recipe-profile-v60",
            title: "V60 Single",
            path: "/v60-single",
            isIcedBrew: false,
            cupsCount: .v60Single,
            ratios: [
                .ratio16,
                .ratio18,
                .ratio20
            ],
            info: .init(title: "v60 single title", source: "v60 single src", body: "v60 single body", animation: "v60 single anim")
        )
    }

    static var v60Iced: Self {
        return BrewMethodDTO(
            id: "v60-iced",
            icon: "recipe-profile-v60",
            title: "V60 Iced",
            path: "/v60-iced",
            isIcedBrew: true,
            cupsCount: .unlimited,
            ratios: [
                .ratio16,
                .ratio17,
                .ratio18
            ],
            info: .init(title: "v60 iced title", source: "v60 iced src", body: "v60 iced body", animation: "v60 iced anim")
        )
    }

    static func frenchPress(cupsCount: CupsCountDTO) -> Self {
        return BrewMethodDTO(
            id: "french-press",
            icon: "recipe-profile-french-press",
            title: "French Press",
            path: "/french-press",
            isIcedBrew: false,
            cupsCount: cupsCount,
            ratios: [
                .ratio17,
                .ratio18,
                .ratio20
            ],
            info: .init(title: "french press title", source: "french press src", body: "french press body", animation: "french press anim")
        )
    }
}

extension CupsCountDTO {
    static var v60Single: Self {
        return CupsCountDTO(minimum: 1, maximum: 1)
    }

    static var unlimited: Self {
        return CupsCountDTO(minimum: 1, maximum: nil)
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
            .init(action: .putCoffee(.init(amount: 10, type: .gram)), requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put all your 10.0 grams of coffee to brewer", details: nil),
            .init(action: .message, requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .userInteractive, message: "Wet filter on hot tap water", details: nil),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto, message: "To bloom, pour 40.0 millilitres of water\nTotal: 40.0 millilitres of water", details: nil),
            .init(action: .pause, requirement: .countdown(30), startMethod: .auto, passMethod: .auto, message: "Let it bloom for 30.0 seconds", details: nil),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .userInteractive, message: "Pour 40.0 millilitres of water", details: "Total: 80.0 millilitres of water"),
            .init(action: .pourWater(.init(amount: 120, type: .millilitre)), requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Use all remaining 120.0 millilitres of water", details: nil)
        ])
    }

    static var stubMiniIced: BrewQueueDTO {
        BrewQueueDTO(stages: [
            .init(action: .putIce(.init(amount: 80, type: .gram)), requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put 80.0 g of ice into the vessel", details: nil),
            .init(action: .putCoffee(.init(amount: 10, type: .gram)), requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put all your 10.0 grams of coffee to brewer", details: nil),
            .init(action: .message, requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .userInteractive, message: "Wet filter on hot tap water", details: nil),
            .init(action: .pourWater(.init(amount: 24, type: .millilitre)), requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto, message: "To bloom, pour 24.0 millilitres of water\nTotal: 24.0 millilitres of water", details: nil),
            .init(action: .pause, requirement: .countdown(30), startMethod: .auto, passMethod: .auto, message: "Let it bloom for 30.0 seconds", details: nil),
            .init(action: .pourWater(.init(amount: 24, type: .millilitre)), requirement: BrewStageRequirementDTO.none, startMethod: .auto, passMethod: .userInteractive, message: "Pour 24.0 millilitres of water", details: "Total: 48.0 millilitres of water"),
            .init(action: .pourWater(.init(amount: 72, type: .millilitre)), requirement: BrewStageRequirementDTO.none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Use all remaining 72.0 millilitres of water", details: nil)
        ])
    }
}

extension RecipeDTO {
    static var stubMini: RecipeDTO {
        return RecipeDTO(
            id: UUID().uuidString,
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini,
            cupsCount: 1.0,
            cupSize: 200.0
        )
    }

    static var stubMiniIced: RecipeDTO {
        return RecipeDTO(
            id: UUID().uuidString,
            recipeProfile: .stubMiniIced,
            ingredients: .stubMiniIced,
            brewQueue: .stubMiniIced,
            cupsCount: 1.0,
            cupSize: 200.0
        )
    }
}

extension RecipeDTO {
    var excludingProfile: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: nil,
            ingredients: ingredients,
            brewQueue: brewQueue,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingProfileName: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: .init(name: nil, brewMethod: nil),
            ingredients: ingredients,
            brewQueue: brewQueue,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingBrewMethod: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: .init(name: "", brewMethod: nil),
            ingredients: ingredients,
            brewQueue: brewQueue,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingIngredientType: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: recipeProfile,
            ingredients: [
                .init(ingredientType: nil, amount: ingredients?.first!.amount)
            ],
            brewQueue: brewQueue,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingIngredientAmount: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: recipeProfile,
            ingredients: [
                .init(ingredientType: ingredients?.first!.ingredientType, amount: nil)
            ],
            brewQueue: brewQueue,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingIngredientAmountType: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: recipeProfile,
            ingredients: [
                .init(ingredientType: ingredients?.first!.ingredientType, amount: .init(amount: nil, type: nil))
            ],
            brewQueue: brewQueue,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingBrewQueue: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: recipeProfile,
            ingredients: ingredients,
            brewQueue: nil,
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingBrewStageAction: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: recipeProfile,
            ingredients: ingredients,
            brewQueue: .init(stages: [
                .init(action: nil, requirement: nil, startMethod: nil, passMethod: nil, message: nil, details: nil)
            ]),
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }

    var excludingBrewStageRequirement: Self {
        return RecipeDTO(
            id: id,
            recipeProfile: recipeProfile,
            ingredients: ingredients,
            brewQueue: .init(stages: [
                .init(action: .pause, requirement: nil, startMethod: nil, passMethod: nil, message: nil, details: nil)
            ]),
            cupsCount: cupsCount,
            cupSize: cupSize
        )
    }
}

extension RecipeProfileDTO {
    static var stubMini: RecipeProfileDTO {
        return RecipeProfileDTO(
            name: "My Recipe Mini", 
            brewMethod: .v60Single
        )
    }

    static var stubMiniIced: RecipeProfileDTO {
        return RecipeProfileDTO(
            name: "My Recipe Mini Iced", 
            brewMethod: .v60Iced
        )
    }
}

extension Array where Element == IngredientDTO {
    static var stubMini: [IngredientDTO] {
        return [
            .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
            .init(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
        ]
    }

    static var stubMiniIced: [IngredientDTO] {
        return [
            .init(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
            .init(ingredientType: .water, amount: .init(amount: 120, type: .millilitre)),
            .init(ingredientType: .ice, amount: .init(amount: 80, type: .gram))
        ]
    }
}
