//
//  MessageInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

final class MessageInstructionActionViewModel: ObservableObject {
    let requirement: InstructionRequirementItem = .none
    let startMethod: InstructionInteractionMethodItem = .userInteractive
    let skipMethod: InstructionInteractionMethodItem = .userInteractive
    @Published var message: String
    @Published var details: String

    init(
        message: String,
        details: String
    ) {
        self.message = message
        self.details = details
    }
}

struct MessageInstructionActionView: View {
    @ObservedObject var model: MessageInstructionActionViewModel

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: model.requirement)
                .with(startMethod: model.startMethod)
                .with(skipMethod: model.skipMethod)
                .with(message: $model.message)
                .with(details: $model.details)
                .build()
        }
    }
}

