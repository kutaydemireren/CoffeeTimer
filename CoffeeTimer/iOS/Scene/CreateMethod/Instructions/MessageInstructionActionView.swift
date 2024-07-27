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

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .message = item.wrappedValue.action else {
            return nil
        }
        _item = item
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: .none)
                .with(startMethod: .userInteractive)
                .with(skipMethod: .userInteractive)
                .with(message: $item.messageBinding())
                .with(details: $item.detailsBinding())
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

/* TODO: custom method - convenient instruction views to work with
 Apply below logic to `RecipeInstructionActionView` and remove separated views (`MessageInstructionActionView`)
 This will remove view constraints in the logic, and make single `RecipeInstructionActionView` to rely on the model (e.g. MessageActionModel).

 (e.g. X = requirement)
 -> model is X
   -> model is updatable X
      -> add to builder as binding
   -> model is plain X
      -> add to builder as constant
 -> model is not X
    -> do not display X
 */

extension RecipeInstructionAction {
    private var unsafeModel: Any {
        switch self {
        case .message(let model):
            return model
        case .pause(let model):
            return model
        case .put(let model):
            return model
        }
    }

    var updatableRequirement: UpdatableInstructionActionRequirement? {
        return unsafeModel as? UpdatableInstructionActionRequirement
    }

    var updatableDuration: UpdatableInstructionActionDuration? {
        return unsafeModel as? UpdatableInstructionActionDuration
    }

    var updatableMessage: UpdatableInstructionActionMessage? {
        return unsafeModel as? UpdatableInstructionActionMessage
    }

    var updatableMethod: UpdatableInstructionActionMethod? {
        return unsafeModel as? UpdatableInstructionActionMethod
    }

    var updatableIngredient: UpdatableInstructionActionIngredient? {
        return unsafeModel as? UpdatableInstructionActionIngredient
    }
}

//

extension Binding where Value == RecipeInstructionActionItem {
    func requirementBinding() -> Binding<InstructionRequirementItem> {
        guard let updatableRequirement = wrappedValue.action.updatableRequirement else {
            return .constant(.none)
        }

        return .init {
            updatableRequirement.requirement
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableRequirement.updating(requirement: newValue))
        }
    }

    func messageBinding() -> Binding<String> {
        guard let updatableMessage = wrappedValue.action.updatableMessage else {
            return .constant("")
        }

        return .init {
            updatableMessage.message
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableMessage.updating(message: newValue))
        }
    }

    func detailsBinding() -> Binding<String> {
        guard let updatableMessage = wrappedValue.action.updatableMessage else {
            return .constant("")
        }

        return .init {
            updatableMessage.details
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableMessage.updating(details: newValue))
        }
    }

    func durationBinding() -> Binding<Double> {
        guard let updatableDuration = wrappedValue.action.updatableDuration else {
            return .constant(0)
        }

        return .init {
            updatableDuration.duration
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableDuration.updating(duration: newValue))
        }
    }

    func startMethodBinding() -> Binding<InstructionInteractionMethodItem> {
        guard let updatableMethod = wrappedValue.action.updatableMethod else {
            return .constant(.userInteractive)
        }

        return .init {
            updatableMethod.startMethod
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableMethod.updating(startMethod: newValue))
        }
    }

    func skipMethodBinding() -> Binding<InstructionInteractionMethodItem> {
        guard let updatableMethod = wrappedValue.action.updatableMethod else {
            return .constant(.userInteractive)
        }

        return .init {
            updatableMethod.skipMethod
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableMethod.updating(skipMethod: newValue))
        }
    }

    func ingredientBinding() -> Binding<IngredientTypeItem> {
        guard let updatableIngredient = wrappedValue.action.updatableIngredient else {
            return .constant(.coffee)
        }

        return .init {
            updatableIngredient.ingredient
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableIngredient.updating(ingredient: newValue))
        }
    }

    func amountBinding() -> Binding<String> {
        guard let updatableIngredient = wrappedValue.action.updatableIngredient else {
            return .constant("")
        }

        return .init {
            updatableIngredient.amount
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: updatableIngredient.updating(amount: newValue))
        }
    }
}
