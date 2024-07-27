//
//  RecipeInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

struct RecipeInstructionActionView: View {
    @Binding var item: RecipeInstructionActionItem
    @State var allActions: [RecipeInstructionAction]

    init(item: Binding<RecipeInstructionActionItem>) {
        _item = item
        allActions = [item.wrappedValue.action] + [
            .message(.init(message: "", details: "")),
            .pause(.init(duration: 0, message: "", details: "")),
            .put(.init(requirement: .none, duration: 0, startMethod: .userInteractive, skipMethod: .userInteractive, message: "", details: "", ingredient: .coffee, amount: ""))
        ].filter {
            item.wrappedValue.action.title != $0.title
        }
    }

    var body: some View {
        actionView
            .padding()
    }

    @ViewBuilder
    var actionView: some View {
        VStack {
            
            TitledPicker(
                selectedItem: .init(
                    get: {
                        item.action
                    },
                    set: { newValue in
                        guard let newValue else { return }
                        item = item.updating(action: newValue)
                    }
                ) ,
                allItems: $allActions,
                title: "Action Type",
                placeholder: ""
            )

            switch item.action {
            case .put:
                PutInstructionActionView(item: $item)
            case .pause:
                PauseInstructionActionView(item: $item)
            case .message:
                MessageInstructionActionView(item: $item)
            }
        }
    }
}

#Preview {
    RecipeInstructionActionView(item: .constant(.stubPause))
}
