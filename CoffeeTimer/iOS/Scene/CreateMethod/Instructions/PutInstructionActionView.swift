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
//                .with(requirement: $item.requirement)
                .with(duration: $item.durationBinding())
//                .with(startMethod: $item.startMethod)
//                .with(skipMethod: $item.skipMethod)
                .with(message: $item.messageBinding())
                .with(details: $item.detailsBinding())
//                .with(ingredient: $item.ingredient)
//                .with(amount: $item.amount)
                .build()
        }
    }
}
