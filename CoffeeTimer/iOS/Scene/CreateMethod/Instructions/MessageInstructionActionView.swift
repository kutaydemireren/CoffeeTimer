//
//  MessageInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

struct MessageInstructionActionView: View {
    /// The input and output source of the view
    @Binding var item: RecipeInstructionActionItem

    private let model: MessageActionModel

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .message(let model) = item.wrappedValue.action else {
            return nil
        }
        _item = item
        self.model = model
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: model.requirement)
                .with(startMethod: model.startMethod)
                .with(skipMethod: model.skipMethod)
                .with(message:  model.messageBinding(to: $item))
                .with(details: model.detailsBinding(to: $item))
                .build()
        }
    }
}

// TODO: move
protocol UpdatableInstructionActionMessage {
    var message: String { get }
    var details: String { get }
    func updating(message: String) -> RecipeInstructionAction
    func updating(details: String) -> RecipeInstructionAction
}

extension MessageActionModel: UpdatableInstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .message(.init(message: message, details: details))
    }

    func updating(details: String) -> RecipeInstructionAction {
        .message(.init(message: message, details: details))
    }
}

extension PauseActionModel: UpdatableInstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
    }

    func updating(details: String) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
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

//

protocol UpdatableInstructionActionDuration {
    var duration: Double { get }
    func updating(duration: Double) -> RecipeInstructionAction
}

extension PauseActionModel: UpdatableInstructionActionDuration {
    func updating(duration: Double) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
    }
}

extension PutActionModel: UpdatableInstructionActionDuration {
    func updating(duration: Double) -> RecipeInstructionAction {
        .put(updating(duration: duration))
    }
}

//

protocol UpdatableInstructionActionRequirement {
    var requirement: InstructionRequirementItem { get }
    func updating(requirement: InstructionRequirementItem) -> RecipeInstructionAction
}

extension PutActionModel: UpdatableInstructionActionRequirement {
    func updating(requirement: InstructionRequirementItem) -> RecipeInstructionAction {
        .put(updating(requirement: requirement))
    }
}

//

protocol UpdatableInstructionActionMethod {
    var startMethod: InstructionInteractionMethodItem { get }
    var skipMethod: InstructionInteractionMethodItem { get }
    func updating(startMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction
    func updating(skipMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction
}

extension PutActionModel: UpdatableInstructionActionMethod {
    func updating(startMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction {
        .put(updating(startMethod: startMethod))
    }
    
    func updating(skipMethod: InstructionInteractionMethodItem) -> RecipeInstructionAction {
        .put(updating(skipMethod: skipMethod))
    }
}

//

protocol UpdatableInstructionActionIngredient {
    var ingredient: IngredientTypeItem { get }
    var amount: String { get }
    func updating(ingredient: IngredientTypeItem) -> RecipeInstructionAction
    func updating(amount: String) -> RecipeInstructionAction
}

extension PutActionModel: UpdatableInstructionActionIngredient {
    func updating(ingredient: IngredientTypeItem) -> RecipeInstructionAction {
        .put(updating(ingredient: ingredient))
    }

    func updating(amount: String) -> RecipeInstructionAction {
        .put(updating(amount: amount))
    }
}

//

extension UpdatableInstructionActionRequirement {
    func requirementBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<InstructionRequirementItem> {
        return .init {
            requirement
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(requirement: newValue))
        }
    }
}

extension UpdatableInstructionActionDuration {
    func durationBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<Double> {
        return .init {
            duration
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(duration: newValue))
        }
    }
}

extension UpdatableInstructionActionMethod {
    func startMethodBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<InstructionInteractionMethodItem> {
        return .init {
            startMethod
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(startMethod: newValue))
        }
    }

    func skipMethodBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<InstructionInteractionMethodItem> {
        return .init {
            skipMethod
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(skipMethod: newValue))
        }
    }
}

extension UpdatableInstructionActionMessage {
    func messageBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<String> {
        return .init {
            message
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(message: newValue))
        }
    }

    func detailsBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<String> {
        return .init {
            details
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(details: newValue))
        }
    }
}

extension UpdatableInstructionActionIngredient {
    func ingredientBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<IngredientTypeItem> {
        return .init {
            ingredient
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(ingredient: newValue))
        }
    }

    func amountBinding(to item: Binding<RecipeInstructionActionItem>) -> Binding<String> {
        return .init {
            amount
        } set: { newValue in
            item.wrappedValue = item.wrappedValue.updating(action: updating(amount: newValue))
        }
    }
}
