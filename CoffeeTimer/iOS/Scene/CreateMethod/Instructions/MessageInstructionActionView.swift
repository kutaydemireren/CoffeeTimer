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

    init(actionModel: MessageActionModel) {
        self.actionModel = actionModel
        self.message = actionModel.message
        self.details = actionModel.details
    }
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
        viewModel = .init(actionModel: model)
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: viewModel.actionModel.requirement)
                .with(startMethod: viewModel.actionModel.startMethod)
                .with(skipMethod: viewModel.actionModel.skipMethod)
                .with(message: $viewModel.message)
                .with(details: $viewModel.details)
                .build()
        }
        .onChange(of: viewModel.message) { newValue in
            viewModel.actionModel = .init(message: newValue, details: viewModel.actionModel.details)
        }
        .onChange(of: viewModel.actionModel) { newValue in
            item = item.updating(action: .message(newValue))
        }
    }
}
