//
//  PutActionModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 27/07/2024.
//

import Foundation

struct PutActionModel: Hashable, Equatable {
    let requirement: InstructionRequirementItem
    let duration: Double
    let startMethod: InstructionInteractionMethodItem
    let skipMethod: InstructionInteractionMethodItem
    let message: String
    let details: String
    let ingredient: IngredientTypeItem
    let mainFactor: Double
    let mainFactorOf: KeywordItem
    let adjustmentFactor: Double
    let adjustmentFactorOf: KeywordItem

    func updating(
        requirement: InstructionRequirementItem? = nil,
        duration: Double? = nil,
        startMethod: InstructionInteractionMethodItem? = nil,
        skipMethod: InstructionInteractionMethodItem? = nil,
        message: String? = nil,
        details: String? = nil,
        ingredient: IngredientTypeItem? = nil,
        mainFactor: Double? = nil,
        mainFactorOf: KeywordItem? = nil,
        adjustmentFactor: Double? = nil,
        adjustmentFactorOf: KeywordItem? = nil

    ) -> Self {
        .init(
            requirement: requirement ?? self.requirement,
            duration: duration ?? self.duration,
            startMethod: startMethod ?? self.startMethod,
            skipMethod: skipMethod ?? self.skipMethod,
            message: message ?? self.message,
            details: details ?? self.details,
            ingredient: ingredient ?? self.ingredient,
            mainFactor: mainFactor ?? self.mainFactor,
            mainFactorOf: mainFactorOf ?? self.mainFactorOf,
            adjustmentFactor: adjustmentFactor ?? self.adjustmentFactor,
            adjustmentFactorOf: adjustmentFactorOf ?? self.adjustmentFactorOf
        )
    }
}

extension PutActionModel: UpdatableInstructionActionRequirement {
    func updating(requirement: InstructionRequirementItem) -> RecipeInstructionAction {
        .put(updating(requirement: requirement))
    }
}

extension PutActionModel: UpdatableInstructionActionDuration {
    func updating(duration: Double) -> RecipeInstructionAction {
        .put(updating(duration: duration))
    }
}

extension PutActionModel: UpdatableInstructionActionMethod {
    func updating(startMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction {
        .put(updating(startMethod: startMethod))
    }

    func updating(skipMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction {
        .put(updating(skipMethod: skipMethod))
    }
}

extension PutActionModel: UpdatableInstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .put(updating(message: message))
    }

    func updating(details: String) -> RecipeInstructionAction {
        .put(updating(details: details))
    }
}

extension PutActionModel: UpdatableInstructionActionIngredient {
    func updating(ingredient: IngredientTypeItem) -> RecipeInstructionAction {
        .put(updating(ingredient: ingredient))
    }

    func updating(mainFactor: Double) -> RecipeInstructionAction {
        .put(updating(mainFactor: mainFactor))
    }

    func updating(mainFactorOf: KeywordItem) -> RecipeInstructionAction {
        .put(updating(mainFactorOf: mainFactorOf))
    }

    func updating(adjustmentFactor: Double) -> RecipeInstructionAction {
        .put(updating(adjustmentFactor: adjustmentFactor))
    }
    func updating(adjustmentFactorOf: KeywordItem) -> RecipeInstructionAction {
        .put(updating(adjustmentFactorOf: adjustmentFactorOf))
    }
}
