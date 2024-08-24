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
//                .with(requirement: Binding(model.requirementBinding(to: $item)))
//                .with(duration: model.durationBinding(to: $item))
//                .with(startMethod: Binding(model.startMethodBinding(to: $item)))
//                .with(skipMethod: Binding(model.skipMethodBinding(to: $item)))
                .with(message: model.messageBinding(to: $action))
//                .with(details: model.detailsBinding(to: $item))
//                .with(ingredient: Binding(model.ingredientBinding(to: $item)))
//                .with(amount: model.amountBinding(to: $item))
                .build()
        }
    }
}
