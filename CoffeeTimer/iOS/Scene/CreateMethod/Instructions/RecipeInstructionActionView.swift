//
//  RecipeInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

struct RecipeInstructionActionView: View {
    /// The input and the output source of this view.
    ///
    /// `item` is updated only initially and once the view is disappeared.
    /// Separating i/o prevents not updating the actual data source until it is confirmed, where the confirmation is assumed to be dismissing the view.
    @Binding var item: RecipeInstructionActionItem
    @State private var selectedAction: RecipeInstructionAction
    @State private var allActions: [RecipeInstructionAction]

    init(item: Binding<RecipeInstructionActionItem>) {
        _item = item
        selectedAction = item.wrappedValue.action
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
            .backgroundPrimary()
    }

    @ViewBuilder
    var actionView: some View {
        ScrollView {
            VStack {
                TitledPicker(
                    selectedItem: Binding($selectedAction),
                    allItems: $allActions,
                    title: "Action Type",
                    placeholder: ""
                )

                switch selectedAction {
                case .put:
                    PutInstructionActionView(action: $selectedAction)
                case .pause:
                    PauseInstructionActionView(action: $selectedAction)
                case .message:
                    MessageInstructionActionView(action: $selectedAction)
                }
            }
        }
        .onChange(of: selectedAction, perform: didUpdate(selectionAction:))
        .scrollIndicators(.hidden)
        .onDisappear {
            item = item.updating(action: selectedAction)
        }
    }

    private func didUpdate(selectionAction: RecipeInstructionAction) {
        allActions[allActions.map { $0.title }.firstIndex(of: selectionAction.title)!] = selectionAction
    }
}

#Preview {
    RecipeInstructionActionView(item: .constant(.stubPause))
}
