//
//  MessageInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

struct MessageInstructionActionView: View {
    @Binding var action: RecipeInstructionAction

    private let model: MessageActionModel

    init?(action: Binding<RecipeInstructionAction>) {
        guard case .message(let model) = action.wrappedValue else {
            return nil
        }
        _action = action
        self.model = model
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: model.requirement)
                .with(startMethod: model.startMethod)
                .with(skipMethod: model.skipMethod)
                .with(message:  model.messageBinding(to: $action))
                .with(details: model.detailsBinding(to: $action))
                .build()
        }
    }
}
