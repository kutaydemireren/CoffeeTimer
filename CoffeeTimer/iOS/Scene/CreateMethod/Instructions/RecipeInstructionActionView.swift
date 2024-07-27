//
//  RecipeInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

struct RecipeInstructionActionView: View {
    @Binding var item: RecipeInstructionActionItem

    var body: some View {
        actionView
            .padding()
    }

    @ViewBuilder
    var actionView: some View {
        switch item.action {
        case .put:
            if let view = PutInstructionActionView(item: $item) {
                view
            }
        case .pause:
            if let view = PauseInstructionActionView(item: $item) {
                view
            }
        case .message:
            if let view = MessageInstructionActionView(item: $item) {
                view
            }
        }
    }
}

#Preview {
    RecipeInstructionActionView(item: .constant(.stubPause))
}
