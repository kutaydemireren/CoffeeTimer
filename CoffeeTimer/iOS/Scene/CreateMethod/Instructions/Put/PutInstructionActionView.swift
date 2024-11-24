//
//  PutInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

struct PutInstructionActionView: View {
    /// The input and output source of the view
    @Binding var action: RecipeInstructionAction

    private let model: PutActionModel

    init?(action: Binding<RecipeInstructionAction>) {
        guard case .put(let model) = action.wrappedValue else {
            return nil
        }
        _action = action
        self.model = model
    }

    var body: some View {
        EmptyView()
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: Binding(model.requirementBinding(to: $action)))
                .with(duration: model.durationBinding(to: $action))
                .with(startMethod: Binding(model.startMethodBinding(to: $action)))
                .with(skipMethod: Binding(model.skipMethodBinding(to: $action)))
                .with(message: model.messageBinding(to: $action))
                .with(details: model.detailsBinding(to: $action))
                .with(ingredient: Binding(model.ingredientBinding(to: $action)))
                .with(mainFactor: model.mainFactorBinding(to: $action))
                .with(mainFactorOf: model.mainFactorOfBinding(to: $action))
                .with(adjustmentFactor: model.adjustmentFactorBinding(to: $action))
                .with(adjustmentFactorOf: model.adjustmentFactorOfBinding(to: $action))
                .build()
        }
    }
}
