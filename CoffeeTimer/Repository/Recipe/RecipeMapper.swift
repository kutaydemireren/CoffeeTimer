//
//  RecipeMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/05/2023.
//

import Foundation

protocol RecipeMapper {
	func mapToRecipe(recipeDTO: RecipeDTO) -> Recipe
	func mapToRecipeDTO(recipe: Recipe) -> RecipeDTO
}

// TODO: throw error
struct RecipeMapperImp: RecipeMapper { }

// MARK: Recipe to RecipeDTO
extension RecipeMapperImp {
	func mapToRecipe(recipeDTO: RecipeDTO) -> Recipe {
		let recipeProfile = mapToRecipeProfile(recipeProfileDTO: recipeDTO.recipeProfile)
		let ingredients = mapToIngredients(ingredientDTOs: recipeDTO.ingredients)
		let brewQueue = mapToBrewQueue(brewQueueDTO: recipeDTO.brewQueue)

		return Recipe(recipeProfile: recipeProfile, ingredients: ingredients, brewQueue: brewQueue)
	}

	private func mapToRecipeProfile(recipeProfileDTO: RecipeProfileDTO?) -> RecipeProfile {
		guard let dto = recipeProfileDTO else {
			// throw ?
			return RecipeProfile(name: "", icon: RecipeProfileIcon(title: "", color: ""))
		}

		let name = dto.name ?? ""
		let icon = mapToRecipeProfileIcon(recipeProfileIconDTO: dto.icon)

		return RecipeProfile(name: name, icon: icon)
	}

	private func mapToRecipeProfileIcon(recipeProfileIconDTO: RecipeProfileIconDTO?) -> RecipeProfileIcon {
		guard let dto = recipeProfileIconDTO else {
			// throw ?
			return RecipeProfileIcon(title: "", color: "")
		}

		let title = dto.title ?? ""
		let color = dto.colorHex ?? ""

		return RecipeProfileIcon(title: title, color: color)
	}

	private func mapToIngredients(ingredientDTOs: [IngredientDTO]?) -> [Ingredient] {
		guard let dtos = ingredientDTOs else {
			return []
		}

		return dtos.compactMap { mapToIngredient(ingredientDTO: $0) }
	}

	private func mapToIngredient(ingredientDTO: IngredientDTO) -> Ingredient {
		let ingredientType = mapToIngredientType(ingredientTypeDTO: ingredientDTO.ingredientType)
		let amount = mapToIngredientAmount(ingredientAmountDTO: ingredientDTO.amount)

		return Ingredient(ingredientType: ingredientType, amount: amount)
	}

	private func mapToIngredientType(ingredientTypeDTO: IngredientTypeDTO?) -> IngredientType {
		guard let dto = ingredientTypeDTO else {
			// throw ?
			return .coffee
		}

		switch dto {
		case .coffee:
			return .coffee
		case .water:
			return .water
		}
	}

	private func mapToIngredientAmount(ingredientAmountDTO: IngredientAmountDTO?) -> IngredientAmount {
		guard let dto = ingredientAmountDTO else {
			// throw ?
			return IngredientAmount(amount: 0, type: .gram)
		}

		let amount = dto.amount ?? 0
		let type = mapToIngredientAmountType(ingredientAmountTypeDTO: dto.type)

		return IngredientAmount(amount: amount, type: type)
	}

	private func mapToIngredientAmountType(ingredientAmountTypeDTO: IngredientAmountTypeDTO?) -> IngredientAmountType {
		guard let dto = ingredientAmountTypeDTO else {
			// throw ?
			return .gram
		}

		switch dto {
		case .spoon:
			return .spoon
		case .gram:
			return .gram
		case .millilitre:
			return .millilitre
		}
	}

	private func mapToBrewQueue(brewQueueDTO: BrewQueueDTO?) -> BrewQueue {
		guard let dto = brewQueueDTO else {
			// throw ?
			return BrewQueue(stages: [])
		}

		let stages = mapToBrewStages(brewStageDTOs: dto.stages)

		return BrewQueue(stages: stages)
	}

	private func mapToBrewStages(brewStageDTOs: [BrewStageDTO]?) -> [BrewStage] {
		guard let dtos = brewStageDTOs else {
			return []
		}

		return dtos.compactMap { mapToBrewStage(brewStageDTO: $0) }
	}

	private func mapToBrewStage(brewStageDTO: BrewStageDTO) -> BrewStage {
		let action = mapToBrewStageAction(brewStageActionDTO: brewStageDTO.action)
		let requirement = mapToBrewStageRequirement(brewStageRequirementDTO: brewStageDTO.requirement)
		let startMethod = brewStageDTO.startMethod ?? .userInteractive

		return BrewStage(action: action, requirement: requirement, startMethod: mapToMethod(brewStageActionMethodDTO: startMethod))
	}

	private func mapToBrewStageAction(brewStageActionDTO: BrewStageActionDTO?) -> BrewStageAction {
		guard let dto = brewStageActionDTO else {
			// throw ?
			return .wet
		}

		switch dto {
		case .boil(let water):
			return .boil(water: mapToIngredientAmount(ingredientAmountDTO: water))
		case .put(let coffee):
			return .put(coffee: mapToIngredientAmount(ingredientAmountDTO: coffee))
		case .pour(let water):
			return .pour(water: mapToIngredientAmount(ingredientAmountDTO: water))
		case .wet:
			return .wet
		case .swirl:
			return .swirl
		case .pause:
			return .pause
		case .finish:
			return .finish
		}
	}

	private func mapToBrewStageRequirement(brewStageRequirementDTO: BrewStageRequirementDTO?) -> BrewStageRequirement {
		guard let dto = brewStageRequirementDTO else {
			// throw ?
			return .none
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

		return RecipeProfileDTO(name: name, icon: icon)
	}

	private func mapToRecipeProfileIconDTO(recipeProfileIcon: RecipeProfileIcon) -> RecipeProfileIconDTO {
		let title = recipeProfileIcon.title
		let colorHex = recipeProfileIcon.color
		let imageName = recipeProfileIcon.imageName

		return RecipeProfileIconDTO(title: title, colorHex: colorHex, imageName: imageName)
	}

	private func mapToIngredientDTOs(ingredients: [Ingredient]) -> [IngredientDTO] {
		return ingredients.map { mapToIngredientDTO(ingredient: $0) }
	}

	private func mapToIngredientDTO(ingredient: Ingredient) -> IngredientDTO {
		let ingredientType = mapToIngredientTypeDTO(ingredientType: ingredient.ingredientType)
		let amount = mapToIngredientAmountDTO(ingredientAmount: ingredient.amount)

		return IngredientDTO(ingredientType: ingredientType, amount: amount)
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
		let amount = ingredientAmount.amount
		let type = mapToIngredientAmountTypeDTO(ingredientAmountType: ingredientAmount.type)

		return IngredientAmountDTO(amount: amount, type: type)
	}

	private func mapToIngredientAmountTypeDTO(ingredientAmountType: IngredientAmountType) -> IngredientAmountTypeDTO {
		switch ingredientAmountType {
		case .spoon:
			return .spoon
		case .gram:
			return .gram
		case .millilitre:
			return .millilitre
		}
	}

	private func mapToBrewQueueDTO(brewQueue: BrewQueue) -> BrewQueueDTO {
		let stages = mapToBrewStageDTOs(brewStages: brewQueue.stages)

		return BrewQueueDTO(stages: stages)
	}

	private func mapToBrewStageDTOs(brewStages: [BrewStage]) -> [BrewStageDTO] {
		return brewStages.map { mapToBrewStageDTO(brewStage: $0) }
	}

	private func mapToBrewStageDTO(brewStage: BrewStage) -> BrewStageDTO {
		let action = mapToBrewStageActionDTO(brewStageAction: brewStage.action)
		let requirement = mapToBrewStageRequirementDTO(brewStageRequirement: brewStage.requirement)
		let startMethod = brewStage.startMethod
		let passMethod = brewStage.passMethod

		return BrewStageDTO(action: action, requirement: requirement, startMethod: mapToMethodDTO(brewStageActionMethod: startMethod), passMethod: mapToMethodDTO(brewStageActionMethod: passMethod))
	}

	private func mapToBrewStageActionDTO(brewStageAction: BrewStageAction) -> BrewStageActionDTO {
		switch brewStageAction {
		case .boil(let water):
			return .boil(water: mapToIngredientAmountDTO(ingredientAmount: water))
		case .put(let coffee):
			return .put(coffee: mapToIngredientAmountDTO(ingredientAmount: coffee))
		case .pour(let water):
			return .pour(water: mapToIngredientAmountDTO(ingredientAmount: water))
		case .wet:
			return .wet
		case .swirl:
			return .swirl
		case .pause:
			return .pause
		case .finish:
			return .finish
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
