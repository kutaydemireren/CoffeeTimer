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

extension RecipeInstructionActionItem {
    var actionMessage: InstructionActionMessage {
        switch action {
        case .message(let model):
            return model
        case .pause:
            fatalError("not implemented")
        case .put:
            fatalError("not implemented")
        }
    }
}

extension Binding where Value == RecipeInstructionActionItem {
    func messageBinding() -> Binding<String> {
        return .init {
            wrappedValue.actionMessage.message
        } set: { newMessage in
            wrappedValue = wrappedValue.updating(action: wrappedValue.actionMessage.updating(message: newMessage))
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
        return .init(get: {
            switch wrappedValue.action {
            case .message:
                return 0
            case .pause(let model):
                return model.duration
            case .put(let model):
                return model.duration
            }
        }, set: { newValue in
            switch wrappedValue.action {
            case .message:
                return
            case .pause(let model):
                wrappedValue = wrappedValue.updating(action: .pause(.init(duration: newValue, message: model.message, details: model.details)))
            case .put:
                fatalError("not implemented")
            }
        })
    }
}
