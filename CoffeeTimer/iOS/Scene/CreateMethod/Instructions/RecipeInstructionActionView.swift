//
//  RecipeInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

struct RecipeInstructionActionItem: Identifiable {
    let id: UUID
    let action: RecipeInstructionAction

    init(id: UUID = UUID(), action: RecipeInstructionAction) {
        self.id = id
        self.action = action
    }
}

extension RecipeInstructionActionItem {
    func updating(action: RecipeInstructionAction) -> Self {
        return Self.init(id: id, action: action)
    }
}

let builder = InstructionActionViewBuilder()

struct RecipeInstructionActionView: View {
    @Binding var item: RecipeInstructionActionItem

    var body: some View {
//        actionView
//            .padding()
        requirementIfNeeded()
            .build()
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

    private func requirementIfNeeded() -> InstructionActionViewBuilder {
        if let requirement = item.action.requirement {
            if let updatableRequirement = item.action.updatableRequirement {
                return builder.with(requirement: .init(get: {
                    updatableRequirement.requirement
                }, set: { newValue in
                    item = item.updating(action: updatableRequirement.updating(requirement: newValue ?? requirement.requirement))
                }))
            } else {
                return builder.with(requirement: requirement.requirement)
            }
        }

        return builder
    }
}

#Preview {
    RecipeInstructionActionView(item: .constant(.stubPause))
}
