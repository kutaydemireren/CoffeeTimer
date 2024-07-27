//
//  MessageInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

final class MessageInstructionActionViewModel: ObservableObject {
    @Published var actionModel: MessageActionModel
    @Published var message: String
    @Published var details: String

    init(
        message: String,
        details: String
    ) {
        self.actionModel = .init(message: message, details: details)
        self.message = message
        self.details = details
    }
}

struct MessageActionModel: Equatable {
    let requirement: InstructionRequirementItem = .none
    let startMethod: InstructionInteractionMethodItem = .userInteractive
    let skipMethod: InstructionInteractionMethodItem = .userInteractive
    let message: String
    let details: String
}

struct MessageInstructionActionView: View {
    /// The input and output source of the view
    @Binding var item: RecipeInstructionActionItem
    @ObservedObject private var viewModel: MessageInstructionActionViewModel

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .message(let model) = item.wrappedValue.action else {
            return nil
        }
        _item = item
        self.viewModel = .init(message: model.message, details: model.details)
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: .none)
                .with(startMethod: .userInteractive)
                .with(skipMethod: .userInteractive)
                .with(message: $viewModel.message)
                .with(details: $viewModel.details)
                .build()
        }
        .onChange(of: viewModel.message) { newValue in
            viewModel.actionModel = .init(message: newValue, details: viewModel.actionModel.details)
        }
        .onChange(of: viewModel.actionModel) { newValue in
            item = .init(action: .message(newValue))
        }
    }
}
