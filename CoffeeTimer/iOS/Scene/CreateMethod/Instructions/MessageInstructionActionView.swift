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
                .with(message: .init(get: {
                    guard case .message(let model) = item.action else { return "" }
                    return model.message
                }, set: { newValue in
                    guard case .message(let model) = item.action else { return }
                    item = item.updating(action: .message(.init(message: newValue, details: model.details)))
                }))
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
extension Binding where Value == RecipeInstructionActionItem {
    func messageBinding() -> Binding<String> {
        return Binding<String>(get: {
            switch wrappedValue.action {
            case .message(let model):
                return model.message
            case .pause(let model):
                return model.message
            case .put(let model):
                return model.message
            }
        }, set: { newValue in
            switch wrappedValue.action {
            case .message(let model):
                wrappedValue = wrappedValue.updating(action: .message(.init(message: newValue, details: model.details)))
            case .pause(let model):
                wrappedValue = wrappedValue.updating(action: .pause(.init(duration: model.duration, message: newValue, details: model.details)))
            case .put(let model):
                fatalError("not implemented")
            }
        })
    }

    func amountBinding() -> Binding<Double> {
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
            case .put(let model):
                fatalError("not implemented")
            }
        })
    }
}
