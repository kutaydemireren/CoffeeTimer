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
                .with(details: .init(get: {
                    guard case .message(let model) = item.action else { return "" }
                    return model.details
                }, set: { newValue in
                    guard case .message(let model) = item.action else { return }
                    item = item.updating(action: .message(.init(message: model.message, details: newValue)))
                }))
                .build()
        }
    }
}

// TODO: move
protocol InstructionActionMessage {
    var message: String { get }
    func updating(message: String) -> RecipeInstructionAction
}

extension MessageActionModel: InstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .message(.init(message: message, details: details))
    }
}

extension PauseActionModel: InstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
    }
}

//

protocol InstructionActionDuration {
    var duration: Double { get }
    func updating(duration: Double) -> RecipeInstructionAction
}

extension PauseActionModel: InstructionActionDuration {
    func updating(duration: Double) -> RecipeInstructionAction {
        return .pause(.init(duration: duration, message: message, details: details))
    }
}

//

extension RecipeInstructionAction {
    var message: InstructionActionMessage {
        switch self {
        case .message(let model):
            return model
        case .pause(let model):
            return model
        case .put:
            fatalError("not implemented")
        }
    }

    var duration: InstructionActionDuration? {
        switch self {
        case .message(let model):
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
            wrappedValue.action.message.message
        } set: { newMessage in
            wrappedValue = wrappedValue.updating(action: wrappedValue.action.message.updating(message: newMessage))
        }
    }

    func detailBinding() -> Binding<String> {
        return Binding<String>(get: {
            switch wrappedValue.action {
            case .message(let model):
                return model.details
            case .pause(let model):
                return model.details
            case .put(let model):
                return model.details
            }
        }, set: { newValue in
            switch wrappedValue.action {
            case .message(let model):
                wrappedValue = wrappedValue.updating(action: .message(.init(message: model.message, details: newValue)))
            case .pause(let model):
                wrappedValue = wrappedValue.updating(action: .pause(.init(duration: model.duration, message: model.message, details: newValue)))
            case .put:
                fatalError("not implemented")
            }
        })
    }

    func durationBinding() -> Binding<Double> {
        guard let actionDuration = wrappedValue.action.duration else {
            return .constant(0)
        }

        return .init {
            actionDuration.duration
        } set: { newValue in
            wrappedValue = wrappedValue.updating(action: actionDuration.updating(duration: newValue))
        }
    }
}
