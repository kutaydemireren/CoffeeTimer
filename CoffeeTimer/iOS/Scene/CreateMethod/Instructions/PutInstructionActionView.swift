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

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .put = item.wrappedValue.action else {
            return nil
        }
        _item = item
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: Binding($item.requirementBinding()))
                .with(duration: $item.durationBinding())
                .with(startMethod: Binding($item.startMethodBinding()))
                .with(skipMethod: Binding($item.skipMethodBinding()))
                .with(message: $item.messageBinding())
                .with(details: $item.detailsBinding())
                .with(ingredient: Binding($item.ingredientBinding()))
                .with(amount: $item.amountBinding())
                .build()
        }
    }
}
