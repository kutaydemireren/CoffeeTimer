//
//  RecipeMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/05/2023.
//

import Foundation

enum RecipeMapperError: Error {
    case missingRecipeProfile
    case missingRecipeProfileIcon
    case missingIngredientType
    case missingIngredientAmount
    case missingIngredientAmountType
    case missingBrewQueue
    case missingBrewStageAction
    case missingBrewStageRequirement
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
        
        return Recipe(recipeProfile: recipeProfile, ingredients: ingredients, brewQueue: brewQueue)
    }
    
    private func mapToRecipeProfile(recipeProfileDTO: RecipeProfileDTO?) throws -> RecipeProfile {
        guard let dto = recipeProfileDTO else {
            throw RecipeMapperError.missingRecipeProfile
        }
        
        return RecipeProfile(
            name: dto.name ?? "",
            icon: try mapToRecipeProfileIcon(recipeProfileIconDTO: dto.icon),
            cupsCount: 1,
            ratio: .ratio16
        )
    }
    
    private func mapToRecipeProfileIcon(recipeProfileIconDTO: RecipeProfileIconDTO?) throws -> RecipeProfileIcon {
        guard let dto = recipeProfileIconDTO else {
            throw RecipeMapperError.missingRecipeProfileIcon
        }
        
        let title = dto.title ?? ""
        let color = dto.colorHex ?? ""
        
        return RecipeProfileIcon(title: title, color: color)
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
        
        return RecipeDTO(recipeProfile: recipeProfileDTO, ingredients: ingredientDTOs, brewQueue: brewQueueDTO)
    }
    
    private func mapToRecipeProfileDTO(recipeProfile: RecipeProfile) -> RecipeProfileDTO {
        let name = recipeProfile.name
        let icon = mapToRecipeProfileIconDTO(recipeProfileIcon: recipeProfile.icon)
        
        return RecipeProfileDTO(
            name: name,
            icon: icon,
            cupsCount: 1,
            ratio: CoffeeToWaterRatio.ratio16.id
        )
    }
    
    private func mapToRecipeProfileIconDTO(recipeProfileIcon: RecipeProfileIcon) -> RecipeProfileIconDTO {
        return RecipeProfileIconDTO(
            title: recipeProfileIcon.title,
            colorHex: recipeProfileIcon.color,
            imageName: recipeProfileIcon.imageName
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
