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

    private let model: MessageActionModel

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .message(let model) = item.wrappedValue.action else {
            return nil
        }
        _item = item
        self.model = model
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: model.requirement)
                .with(startMethod: model.startMethod)
                .with(skipMethod: model.skipMethod)
                .with(message:  model.messageBinding(to: $item))
                .with(details: model.detailsBinding(to: $item))
                .build()
        }
    }
}
