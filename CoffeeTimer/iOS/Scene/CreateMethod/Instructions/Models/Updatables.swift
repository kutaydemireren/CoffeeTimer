//
//  Updatables.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 27/07/2024.
//

import SwiftUI

// MARK: Requirement
protocol UpdatableInstructionActionRequirement {
    var requirement: InstructionRequirementItem { get }
    func updating(requirement: InstructionRequirementItem) -> RecipeInstructionAction
}

extension UpdatableInstructionActionRequirement {
    func requirementBinding(to item: Binding<RecipeInstructionAction>) -> Binding<InstructionRequirementItem> {
        return .init {
            requirement
        } set: { newValue in
            item.wrappedValue = updating(requirement: newValue)
        }
    }
}

// MARK: Duration
protocol UpdatableInstructionActionDuration {
    var duration: Double { get }
    func updating(duration: Double) -> RecipeInstructionAction
}

extension UpdatableInstructionActionDuration {
    func durationBinding(to item: Binding<RecipeInstructionAction>) -> Binding<Double> {
        return .init {
            duration
        } set: { newValue in
            item.wrappedValue = updating(duration: newValue)
        }
    }
}

// MARK: Interaction Method
protocol UpdatableInstructionActionMethod {
    var startMethod: InstructionInteractionMethodItem { get }
    var skipMethod: InstructionInteractionMethodItem { get }
    func updating(startMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction
    func updating(skipMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction
}

extension UpdatableInstructionActionMethod {
    func startMethodBinding(to item: Binding<RecipeInstructionAction>) -> Binding<InstructionInteractionMethodItem> {
        return .init {
            startMethod
        } set: { newValue in
            item.wrappedValue = updating(startMethod: newValue)
        }
    }

    func skipMethodBinding(to item: Binding<RecipeInstructionAction>) -> Binding<InstructionInteractionMethodItem> {
        return .init {
            skipMethod
        } set: { newValue in
            item.wrappedValue = updating(skipMethod: newValue)
        }
    }
}

// MARK: Message
protocol UpdatableInstructionActionMessage {
    var message: String { get }
    var details: String { get }
    func updating(message: String) -> RecipeInstructionAction
    func updating(details: String) -> RecipeInstructionAction
}

extension UpdatableInstructionActionMessage {
    func messageBinding(to item: Binding<RecipeInstructionAction>) -> Binding<String> {
        return .init {
            message
        } set: { newValue in
            item.wrappedValue = updating(message: newValue)
        }
    }

    func detailsBinding(to item: Binding<RecipeInstructionAction>) -> Binding<String> {
        return .init {
            details
        } set: { newValue in
            item.wrappedValue = updating(details: newValue)
        }
    }
}

// MARK: Ingredient
protocol UpdatableInstructionActionIngredient {
    var ingredient: IngredientTypeItem { get }
    var amount: String { get }
    func updating(ingredient: IngredientTypeItem) -> RecipeInstructionAction
    func updating(amount: String) -> RecipeInstructionAction
}

extension UpdatableInstructionActionIngredient {
    func ingredientBinding(to item: Binding<RecipeInstructionAction>) -> Binding<IngredientTypeItem> {
        return .init {
            ingredient
        } set: { newValue in
            item.wrappedValue = updating(ingredient: newValue)
        }
    }

    func amountBinding(to item: Binding<RecipeInstructionAction>) -> Binding<String> {
        return .init {
            amount
        } set: { newValue in
            item.wrappedValue = updating(amount: newValue)
        }
    }
}
