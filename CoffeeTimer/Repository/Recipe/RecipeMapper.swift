//
//  RecipeMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/05/2023.
//

import Foundation

enum RecipeMapperError: Error {
    case missingRecipeProfile
    case missingProfileName
    case missingBrewMethod
    case missingIngredientType
    case missingIngredientAmount
    case missingIngredientAmountType
    case missingBrewQueue
    case missingBrewStageAction
    case missingBrewStageRequirement
    case missingRecipeId
}

protocol RecipeMapper {
    func mapToRecipe(recipeDTO: RecipeDTO) throws -> Recipe
    func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO
}

extension IngredientAmountTypeDTO {
    func map() -> IngredientAmountType {
        switch self {
        case .gram:
            return .gram
        case .millilitre:
            return .millilitre
        }
    }
}

struct RecipeMapperImp: RecipeMapper { }

// MARK: Recipe to RecipeDTO
extension RecipeMapperImp {
    func mapToRecipe(recipeDTO: RecipeDTO) throws -> Recipe {
        let recipeProfile = try mapToRecipeProfile(recipeProfileDTO: recipeDTO.recipeProfile)
        let ingredients = try mapToIngredients(ingredientDTOs: recipeDTO.ingredients)
        let brewQueue = try mapToBrewQueue(brewQueueDTO: recipeDTO.brewQueue)
        
        // Default values when cupsCount/cupSize are missing
        let cupsCount = recipeDTO.cupsCount ?? 1.0
        let cupSize: Double
        if let persistedCupSize = recipeDTO.cupSize {
            cupSize = persistedCupSize
        } else {
            // Calculate from total liquid when cupSize is missing
            let waterMl = Double(ingredients.first(where: { $0.ingredientType == .water })?.amount.amount ?? 0)
            let iceAmount = Double(ingredients.first(where: { $0.ingredientType == .ice })?.amount.amount ?? 0)
            let isIced = recipeProfile.brewMethod.isIcedBrew
            let totalLiquid = isIced ? waterMl + iceAmount : waterMl
            cupSize = totalLiquid
        }
        
        // Map ID - recipe must have a valid ID
        guard let idString = recipeDTO.id,
              let uuid = UUID(uuidString: idString) else {
            throw RecipeMapperError.missingRecipeId
        }
        
        let id = uuid
        
        return Recipe(id: id, recipeProfile: recipeProfile, ingredients: ingredients, brewQueue: brewQueue, cupsCount: cupsCount, cupSize: cupSize)
    }
    
    private func mapToRecipeProfile(recipeProfileDTO: RecipeProfileDTO?) throws -> RecipeProfile {
        guard let dto = recipeProfileDTO else { throw RecipeMapperError.missingRecipeProfile }
        guard let name = dto.name else { throw RecipeMapperError.missingProfileName }

        return RecipeProfile(
            name: name,
            brewMethod: try mapToBrewMethod(brewMethodDTO: dto.brewMethod)
        )
    }

    private func mapToBrewMethod(brewMethodDTO: BrewMethodDTO?) throws -> BrewMethod {
        guard let brewMethodDTO else { throw RecipeMapperError.missingBrewMethod }

        return BrewMethod(
            id: brewMethodDTO.id ?? "",
            iconName: brewMethodDTO.icon ?? "recipe-profile-gooseneck-kettle",
            title: brewMethodDTO.title ?? "",
            path: brewMethodDTO.path ?? "",
            isIcedBrew: brewMethodDTO.isIcedBrew ?? false,
            cupsCount: CupsCount(minimum: brewMethodDTO.cupsCount?.minimum ?? 1, maximum: brewMethodDTO.cupsCount?.maximum),
            ratios: brewMethodDTO.ratios.map { CoffeeToWaterRatio(id: $0.id ?? "", value: $0.value ?? 0, title: $0.title ?? "" ) },
            info: map(infoModel: brewMethodDTO.info, fallbackTitle: brewMethodDTO.title ?? "")
        )
    }

    private func map(infoModel: InfoModelDTO?, fallbackTitle: String) -> InfoModel {
        guard let infoModel else {
            return .init(title: fallbackTitle, body: "")
        }

        return .init(
            title: infoModel.title ?? fallbackTitle,
            source: infoModel.source,
            body: infoModel.body ?? "",
            animation: infoModel.animation
        )
    }

    private func mapToIngredients(ingredientDTOs: [IngredientDTO]?) throws -> [Ingredient] {
        guard let dtos = ingredientDTOs else {
            return []
        }
        
        return try dtos.compactMap { try mapToIngredient(ingredientDTO: $0) }
    }
    
    private func mapToIngredient(ingredientDTO: IngredientDTO) throws -> Ingredient {
        let ingredientType = try mapToIngredientType(ingredientTypeDTO: ingredientDTO.ingredientType)
        let amount = try mapToIngredientAmount(ingredientAmountDTO: ingredientDTO.amount)
        
        return Ingredient(ingredientType: ingredientType, amount: amount)
    }
    
    private func mapToIngredientType(ingredientTypeDTO: IngredientTypeDTO?) throws -> IngredientType {
        guard let dto = ingredientTypeDTO else {
            throw RecipeMapperError.missingIngredientType
        }
        
        switch dto {
        case .coffee:
            return .coffee
        case .water:
            return .water
        case .ice:
            return .ice
        }
    }
    
    private func mapToIngredientAmount(ingredientAmountDTO: IngredientAmountDTO?) throws -> IngredientAmount {
        guard let dto = ingredientAmountDTO else {
            throw RecipeMapperError.missingIngredientAmount
        }
        
        guard let type = dto.type?.map() else {
            throw RecipeMapperError.missingIngredientAmountType
        }
        
        return IngredientAmount(amount: dto.amount ?? 0, type: type)
    }
    
    private func mapToBrewQueue(brewQueueDTO: BrewQueueDTO?) throws-> BrewQueue {
        guard let dto = brewQueueDTO else {
            throw RecipeMapperError.missingBrewQueue
        }
        
        let stages = try mapToBrewStages(brewStageDTOs: dto.stages)
        
        return BrewQueue(stages: stages)
    }
    
    private func mapToBrewStages(brewStageDTOs: [BrewStageDTO]?) throws -> [BrewStage] {
        guard let dtos = brewStageDTOs else {
            return []
        }
        
        return try dtos.compactMap { try mapToBrewStage(brewStageDTO: $0) }
    }
    
    private func mapToBrewStage(brewStageDTO: BrewStageDTO) throws -> BrewStage {
        let action = try mapToBrewStageAction(brewStageActionDTO: brewStageDTO.action)
        let requirement = try mapToBrewStageRequirement(brewStageRequirementDTO: brewStageDTO.requirement)
        let startMethod = brewStageDTO.startMethod ?? .userInteractive
        let passMethod = brewStageDTO.passMethod ?? .userInteractive

        return BrewStage(
            action: action,
            requirement: requirement,
            startMethod: mapToMethod(brewStageActionMethodDTO: startMethod),
            passMethod: mapToMethod(brewStageActionMethodDTO: passMethod),
            message: brewStageDTO.message ?? "",
            details: brewStageDTO.details
        )
    }
    
    private func mapToBrewStageAction(brewStageActionDTO: BrewStageActionDTO?) throws -> BrewStageAction {
        guard let dto = brewStageActionDTO else {
            throw RecipeMapperError.missingBrewStageAction
        }
        
        switch dto {
        case .boilWater(let water):
            return .boilWater(try mapToIngredientAmount(ingredientAmountDTO: water))
        case .putCoffee(let coffee):
            return .putCoffee(try mapToIngredientAmount(ingredientAmountDTO: coffee))
        case .putIce(let ice):
            return .putIce(try mapToIngredientAmount(ingredientAmountDTO: ice))
        case .pourWater(let water):
            return .pourWater(try mapToIngredientAmount(ingredientAmountDTO: water))
        case .wet:
            return .wet
        case .swirl:
            return .swirl
        case .swirlThoroughly:
            return .swirlThoroughly
        case .pause:
            return .pause
        case .finish:
            return .finish
        case .finishIced:
            return .finishIced
        case .message:
            return .message
        }
    }
    
    private func mapToBrewStageRequirement(brewStageRequirementDTO: BrewStageRequirementDTO?) throws -> BrewStageRequirement {
        guard let dto = brewStageRequirementDTO else {
            throw RecipeMapperError.missingBrewStageRequirement
        }
        
        switch dto {
        case .none:
            return .none
        case .countdown(let value):
            return .countdown(value)
        }
    }
    
    private func mapToMethod(brewStageActionMethodDTO: BrewStageActionMethodDTO) -> BrewStageActionMethod {
        switch brewStageActionMethodDTO {
        case .auto:
            return .auto
        case .userInteractive:
            return .userInteractive
        }
    }
}

// MARK: RecipeDTO to Recipe
extension RecipeMapperImp {
    func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO {
        let recipeProfileDTO = mapToRecipeProfileDTO(recipeProfile: recipe.recipeProfile)
        let ingredientDTOs = mapToIngredientDTOs(ingredients: recipe.ingredients)
        let brewQueueDTO = mapToBrewQueueDTO(brewQueue: recipe.brewQueue)
        
        return RecipeDTO(id: recipe.id.uuidString, recipeProfile: recipeProfileDTO, ingredients: ingredientDTOs, brewQueue: brewQueueDTO, cupsCount: recipe.cupsCount, cupSize: recipe.cupSize)
    }
    
    private func mapToRecipeProfileDTO(recipeProfile: RecipeProfile) -> RecipeProfileDTO {
        return RecipeProfileDTO(
            name: recipeProfile.name,
            brewMethod: mapToBrewMethodDTO(brewMethod: recipeProfile.brewMethod)
        )
    }

    private func mapToBrewMethodDTO(brewMethod: BrewMethod) -> BrewMethodDTO {
        return BrewMethodDTO(
            id: brewMethod.id,
            icon: brewMethod.iconName,
            title: brewMethod.title,
            path: brewMethod.path,
            isIcedBrew: brewMethod.isIcedBrew,
            cupsCount: CupsCountDTO(minimum: brewMethod.cupsCount.minimum, maximum: brewMethod.cupsCount.maximum),
            ratios: brewMethod.ratios.map { CoffeeToWaterRatioDTO(id: $0.id, value: $0.value, title: $0.title) },
            info: map(infoModel: brewMethod.info)
        )
    }

    private func map(infoModel: InfoModel) -> InfoModelDTO {
        return .init(
            title: infoModel.title,
            source: infoModel.source,
            body: infoModel.body,
            animation: infoModel.animation
        )
    }

    private func mapToIngredientDTOs(ingredients: [Ingredient]) -> [IngredientDTO] {
        return ingredients.map { mapToIngredientDTO(ingredient: $0) }
    }
    
    private func mapToIngredientDTO(ingredient: Ingredient) -> IngredientDTO {
        return IngredientDTO(
            ingredientType: mapToIngredientTypeDTO(ingredientType: ingredient.ingredientType),
            amount: mapToIngredientAmountDTO(ingredientAmount: ingredient.amount)
        )
    }
    
    private func mapToIngredientTypeDTO(ingredientType: IngredientType) -> IngredientTypeDTO {
        switch ingredientType {
        case .coffee:
            return .coffee
        case .water:
            return .water
        case .ice:
            return .ice
        }
    }
    
    private func mapToIngredientAmountDTO(ingredientAmount: IngredientAmount) -> IngredientAmountDTO {
        return IngredientAmountDTO(
            amount: ingredientAmount.amount,
            type: mapToIngredientAmountTypeDTO(ingredientAmountType: ingredientAmount.type)
        )
    }
    
    private func mapToIngredientAmountTypeDTO(ingredientAmountType: IngredientAmountType) -> IngredientAmountTypeDTO {
        switch ingredientAmountType {
        case .gram:
            return .gram
        case .millilitre:
            return .millilitre
        }
    }
    
    private func mapToBrewQueueDTO(brewQueue: BrewQueue) -> BrewQueueDTO {
        return BrewQueueDTO(stages: mapToBrewStageDTOs(brewStages: brewQueue.stages))
    }
    
    private func mapToBrewStageDTOs(brewStages: [BrewStage]) -> [BrewStageDTO] {
        return brewStages.map { mapToBrewStageDTO(brewStage: $0) }
    }
    
    private func mapToBrewStageDTO(brewStage: BrewStage) -> BrewStageDTO {
        return BrewStageDTO(
            action: mapToBrewStageActionDTO(brewStageAction: brewStage.action),
            requirement: mapToBrewStageRequirementDTO(brewStageRequirement: brewStage.requirement),
            startMethod: mapToMethodDTO(brewStageActionMethod: brewStage.startMethod),
            passMethod: mapToMethodDTO(brewStageActionMethod: brewStage.passMethod),
            message: brewStage.message,
            details: brewStage.details
        )
    }
    
    private func mapToBrewStageActionDTO(brewStageAction: BrewStageAction) -> BrewStageActionDTO {
        switch brewStageAction {
        case .boilWater(let water):
            return .boilWater(mapToIngredientAmountDTO(ingredientAmount: water))
        case .putCoffee(let coffee):
            return .putCoffee(mapToIngredientAmountDTO(ingredientAmount: coffee))
        case .putIce(let ice):
            return .putIce(mapToIngredientAmountDTO(ingredientAmount: ice))
        case .pourWater(let water):
            return .pourWater(mapToIngredientAmountDTO(ingredientAmount: water))
        case .wet:
            return .wet
        case .swirl:
            return .swirl
        case .swirlThoroughly:
            return .swirlThoroughly
        case .pause:
            return .pause
        case .finish:
            return .finish
        case .finishIced:
            return .finishIced
        case .message:
            return .message
        }
    }
    
    private func mapToBrewStageRequirementDTO(brewStageRequirement: BrewStageRequirement) -> BrewStageRequirementDTO {
        switch brewStageRequirement {
        case .none:
            return .none
        case .countdown(let value):
            return .countdown(value)
        }
    }
    
    private func mapToMethodDTO(brewStageActionMethod: BrewStageActionMethod) -> BrewStageActionMethodDTO {
        switch brewStageActionMethod {
        case .auto:
            return .auto
        case .userInteractive:
            return .userInteractive
        }
    }
}
