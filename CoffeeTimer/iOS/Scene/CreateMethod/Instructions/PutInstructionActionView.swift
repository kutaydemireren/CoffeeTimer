//
//  PutInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

final class PutInstructionActionViewModel: ObservableObject {
    @Published var requirement: InstructionRequirementItem?
    @Published var duration: Double
    @Published var startMethod: InstructionInteractionMethodItem?
    @Published var skipMethod: InstructionInteractionMethodItem?
    @Published var message: String
    @Published var details: String
    @Published var ingredient: IngredientTypeItem?
    @Published var amount: String // TODO: parse

    init(
        requirement: InstructionRequirementItem,
        duration: Double = 0,
        startMethod: InstructionInteractionMethodItem,
        skipMethod: InstructionInteractionMethodItem,
        message: String,
        details: String,
        ingredient: IngredientTypeItem,
        amount: String
    ) {
        self.requirement = requirement
        self.duration = duration
        self.startMethod = startMethod
        self.skipMethod = skipMethod
        self.message = message
        self.details = details
        self.ingredient = ingredient
        self.amount = amount
    }
}

struct PutInstructionActionView: View {
    @ObservedObject var model: PutInstructionActionViewModel

    var body: some View {
        VStack {
            InstructionActionViewBuilder()
                .with(requirement: $model.requirement)
                .with(duration: $model.duration)
                .with(startMethod: $model.startMethod)
                .with(skipMethod: $model.skipMethod)
                .with(message: $model.message)
                .with(details: $model.details)
                .with(ingredient: $model.ingredient)
                .with(amount: $model.amount)
                .build()
        }
    }
}
