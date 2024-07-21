//
//  RecipeInstructionStepItemView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

// TODO: move
fileprivate extension RecipeInstructionStepItem {
    static var stubPut: RecipeInstructionStepItem {
        RecipeInstructionStepItem(
            action: .put(.stub)
        )
    }

    static var stubPause: RecipeInstructionStepItem {
        RecipeInstructionStepItem(
            action: .pause(.stub)
        )
    }

    static var stubMessage: RecipeInstructionStepItem {
        RecipeInstructionStepItem(
            action: .message(.stub)
        )
    }
}

extension PutInstructionActionViewModel {
    static var stub: PutInstructionActionViewModel {
        PutInstructionActionViewModel(
            requirement: .unknown,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "put msg",
            details: "dtl",
            ingredient: .coffee,
            amount: ""
        )
    }
}

extension PauseInstructionActionViewModel {
    static var stub: PauseInstructionActionViewModel {
        PauseInstructionActionViewModel(
            message: "pause msg",
            details: "dtl",
            duration: 20
        )
    }
}

extension MessageInstructionActionViewModel {
    static var stub: MessageInstructionActionViewModel {
        MessageInstructionActionViewModel(
            message: "message msg",
            details: "dtl"
        )
    }
}

//

enum RecipeInstructionAction {
    case put(PutInstructionActionViewModel)
    case pause(PauseInstructionActionViewModel)
    case message(MessageInstructionActionViewModel)

    var message: String {
        switch self {
        case .put(let model):
            return model.message
        case .pause(let model):
            return model.message
        case .message(let model):
            return model.message
        }
    }
}

struct RecipeInstructionStepItem: Identifiable {
    let id = UUID()
    let action: RecipeInstructionAction
}

//

struct RecipeInstructionStepItemView: View {
    @State var item: RecipeInstructionStepItem

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
    RecipeInstructionStepItemView(item: .stubMessage)
}

//

final class PutInstructionActionViewModel: ObservableObject {
    @Published var requirement: InstructionRequirement
    @Published var startMethod: InstructionInteractionMethod
    @Published var skipMethod: InstructionInteractionMethod
    @Published var message: String
    @Published var details: String
    @Published var ingredient: IngredientType
    @Published var amount: String // TODO: parse

    init(
        requirement: InstructionRequirement,
        startMethod: InstructionInteractionMethod,
        skipMethod: InstructionInteractionMethod,
        message: String,
        details: String,
        ingredient: IngredientType,
        amount: String
    ) {
        self.requirement = requirement
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
            Text("requirement: \(String(describing: model.requirement))")
            Text("startMethod: \(String(describing: model.startMethod))")
            Text("skipMethod: \(String(describing: model.skipMethod))")
            Text("message: \(String(describing: model.message))")
            Text("details: \(String(describing: model.details))")
            Text("ingredient: \(String(describing: model.ingredient))")
            Text("amount: \(String(describing: model.amount))")
        }
    }
}

//

final class PauseInstructionActionViewModel: ObservableObject {
    let requirement: InstructionRequirement = .countdown(0)
    let startMethod: InstructionInteractionMethod = .auto
    let skipMethod: InstructionInteractionMethod = .auto
    @Published var message: String
    @Published var details: String
    @Published var duration: Double

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
            Text("requirement: \(String(describing: model.requirement))")
            Text("startMethod: \(String(describing: model.startMethod))")
            Text("skipMethod: \(String(describing: model.skipMethod))")
            Text("message: \(String(describing: model.message))")
            Text("details: \(String(describing: model.details))")
            Text("duration: \(String(describing: model.duration))")
        }
    }
}

//

final class MessageInstructionActionViewModel: ObservableObject {
    let requirement: InstructionRequirementItem = .none
    let startMethod: InstructionInteractionMethod = .userInteractive
    let skipMethod: InstructionInteractionMethod = .userInteractive
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
            TitledPicker(
                selectedItem: .constant(model.requirement),
                allItems: .constant(InstructionRequirementItem.allCases),
                title: "Requirement",
                placeholder: ""
            )
            .disabled(true)
            .grayscale(0.5)

            TitledPicker(
                selectedItem: .constant(model.requirement),
                allItems: .constant(InstructionRequirementItem.allCases),
                title: "Start Method",
                placeholder: ""
            )
            .disabled(true)
            .grayscale(0.5)

            Text("startMethod: \(String(describing: model.startMethod))")
            Text("skipMethod: \(String(describing: model.skipMethod))")
            Text("message: \(String(describing: model.message))")
            Text("details: \(String(describing: model.details))")
        }
    }
}

enum InstructionRequirementItem: String, Titled, Hashable, Identifiable, CaseIterable {
    var id: Self {
        return self
    }

    var title: String {
        return rawValue
    }

    case `none` = "none"
    case countknown = "countdown"
}
