//
//  PauseInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

final class PauseInstructionActionViewModel: ObservableObject {
    let requirement: InstructionRequirementItem = .countdown
    @Published var duration: Double
    let startMethod: InstructionInteractionMethodItem = .auto
    let skipMethod: InstructionInteractionMethodItem = .auto
    @Published var message: String
    @Published var details: String

    init(
        message: String,
        details: String,
        duration: Double
    ) {
        self.message = message
        self.details = details
        self.duration = duration
    }
}

struct PauseInstructionActionView: View {
    @ObservedObject var model: PauseInstructionActionViewModel

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: model.requirement)
                .with(duration: $model.duration)
                .with(startMethod: model.startMethod)
                .with(skipMethod: model.skipMethod)
                .with(message: $model.message)
                .with(details: $model.details)
                .build()
        }
    }
}

