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

//

protocol UpdatableInstructionActionDuration {
    var duration: Double { get }
    func updating(duration: Double) -> RecipeInstructionAction
}

extension PauseActionModel: UpdatableInstructionActionDuration {
    func updating(duration: Double) -> RecipeInstructionAction {
        return .pause(.init(duration: duration, message: message, details: details))
    }
}

//

extension RecipeInstructionAction {
    var updatableMessage: UpdatableInstructionActionMessage {
        switch self {
        case .message(let model):
            return model
        case .pause(let model):
            return model
        case .put:
            fatalError("not implemented")
        }
    }

    var updatableDuration: UpdatableInstructionActionDuration? {
        switch self {
        case .message:
            return nil
        case .pause(let model):
            return model
        case .put:
            fatalError("not implemented")
        }
    }
}

//

extension Binding where Value == RecipeInstructionActionItem {
    func messageBinding() -> Binding<String> {
        return .init {
            wrappedValue.action.updatableMessage.message
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: wrappedValue.action.updatableMessage.updating(message: newValue))
        }
    }

    func detailsBinding() -> Binding<String> {
        return .init {
            wrappedValue.action.updatableMessage.details
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: wrappedValue.action.updatableMessage.updating(details: newValue))
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
}
