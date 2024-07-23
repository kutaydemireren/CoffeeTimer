//
//  RecipeInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

struct RecipeInstructionActionItem: Identifiable {
    let id = UUID()
    let action: RecipeInstructionAction
}

struct RecipeInstructionActionView: View {

    @Binding var item: RecipeInstructionActionItem

    var body: some View {
        actionView
            .padding()
    }

    @ViewBuilder
    var actionView: some View {
        switch item.action {
        case .put(let model):
            PutInstructionActionView(model: model)
        case .pause(let model):
            PauseInstructionActionView(model: model)
        case .message(let model):
            MessageInstructionActionView(model: model)
        }
    }
}

#Preview {
    RecipeInstructionActionView(item: .constant(.stubPause))
}
