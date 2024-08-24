//
//  PauseInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

struct PauseInstructionActionView: View {
    /// The input and output source of the view
    @Binding var action: RecipeInstructionAction

    private let model: PauseActionModel

    init?(action: Binding<RecipeInstructionAction>) {
        guard case .pause(let model) = action.wrappedValue else {
            return nil
        }
        _action = action
        self.model = model
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: model.requirement)
//                .with(duration: model.durationBinding(to: $item))
                .with(startMethod: model.startMethod)
                .with(skipMethod: model.skipMethod)
                .with(message: model.messageBinding(to: $action))
//                .with(details: model.detailsBinding(to: $item))
                .build()
        }
    }
}
