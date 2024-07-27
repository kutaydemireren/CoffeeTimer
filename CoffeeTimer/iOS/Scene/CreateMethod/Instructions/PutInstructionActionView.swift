//
//  PutInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

struct PutInstructionActionView: View {
    /// The input and output source of the view
    @Binding var item: RecipeInstructionActionItem

    private let model: PutActionModel

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .put(let model) = item.wrappedValue.action else {
            return nil
        }
        _item = item
        self.model = model
    }

    var body: some View {
        EmptyView()
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: Binding(model.requirementBinding(to: $item)))
                .with(duration: model.durationBinding(to: $item))
                .with(startMethod: Binding(model.startMethodBinding(to: $item)))
                .with(skipMethod: Binding(model.skipMethodBinding(to: $item)))
                .with(message: model.messageBinding(to: $item))
                .with(details: model.detailsBinding(to: $item))
                .with(ingredient: Binding(model.ingredientBinding(to: $item)))
                .with(amount: model.amountBinding(to: $item))
                .build()
        }
    }
}
