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
}

extension PutInstructionActionViewModel {
    static var stub: PutInstructionActionViewModel {
        PutInstructionActionViewModel(
            requirement: .none,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "msg",
            details: "dtl",
            ingredient: .coffee,
            amount: ""
        )
    }
}

//

enum RecipeInstructionAction {
    case put(PutInstructionActionViewModel)
    case pause
    case message

    var message: String {
        switch self {
        case .put(let model):
            return model.message
        case .pause, .message:
            return ""
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
        switch item.action {
        case .put(let model):
            PutInstructionActionView(model: model)
        case .pause, .message:
            EmptyView()
        }
    }
}

#Preview {
    RecipeInstructionStepItemView(item: .stubPut)
}

//

final class PutInstructionActionViewModel: ObservableObject {
    @Published var requirement: BrewStageRequirement
    @Published var startMethod: BrewStageActionMethod
    @Published var skipMethod: BrewStageActionMethod
    @Published var message: String
    @Published var details: String
    @Published var ingredient: IngredientType
    @Published var amount: String // TODO: parse

    init(
        requirement: BrewStageRequirement,
        startMethod: BrewStageActionMethod,
        skipMethod: BrewStageActionMethod,
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
