//
//  PauseInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

final class PauseInstructionActionViewModel: ObservableObject {
    @Published var actionModel: PauseActionModel
    @Published var duration: Double
    @Published var message: String
    @Published var details: String

    init(actionModel: PauseActionModel) {
        self.actionModel = actionModel
        self.duration = actionModel.duration
        self.message = actionModel.message
        self.details = actionModel.details
    }
}

struct PauseInstructionActionView: View {
    /// The input and output source of the view
    @Binding var item: RecipeInstructionActionItem
    @ObservedObject private var viewModel: PauseInstructionActionViewModel

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .pause(let model) = item.wrappedValue.action else {
            return nil
        }
        _item = item
        viewModel = .init(actionModel: model)
    }

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: viewModel.actionModel.requirement)
                .with(duration: $viewModel.duration)
                .with(startMethod: viewModel.actionModel.startMethod)
                .with(skipMethod: viewModel.actionModel.skipMethod)
                .with(message: $viewModel.message)
                .with(details: $viewModel.details)
                .build()
        }
        .onChange(of: viewModel.message) { newValue in
            viewModel.actionModel = .init(duration: viewModel.actionModel.duration, message: viewModel.actionModel.message, details: viewModel.actionModel.details)
        }
        .onChange(of: viewModel.actionModel) { newValue in
            item = item.updating(action: .pause(newValue))
        }
    }
}
