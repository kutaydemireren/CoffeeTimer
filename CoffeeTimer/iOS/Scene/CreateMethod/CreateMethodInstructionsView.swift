//
//  CreateMethodInstructionsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

struct RecipeInstructionStepItem: Identifiable {
    let id = UUID()
    let recipeInstructionStep: RecipeInstructionStep?
}

//

final class CreateMethodInstructionsViewModel: ObservableObject {
    @Published var instructions: [RecipeInstructionStepItem] = [
        .init(
            recipeInstructionStep: RecipeInstructionStep(
                instructionAction: MessageInstructionAction(
                    requirement: nil,
                    startMethod: nil,
                    skipMethod: nil,
                    message: "message 1",
                    details: nil
                )
            )
        ),
        .init(
            recipeInstructionStep: RecipeInstructionStep(
                instructionAction: MessageInstructionAction(
                    requirement: nil,
                    startMethod: nil,
                    skipMethod: nil,
                    message: "message 2",
                    details: nil
                )
            )
        ),
        .init(
            recipeInstructionStep: RecipeInstructionStep(
                instructionAction: MessageInstructionAction(
                    requirement: nil,
                    startMethod: nil,
                    skipMethod: nil,
                    message: "message 3",
                    details: nil
                )
            )
        ),
    ]

    func removeInstruction(at indexSet: IndexSet) {
        instructions.remove(atOffsets: indexSet)
    }

    func moveInstruction(from source: IndexSet, to destination: Int) {
        instructions.move(fromOffsets: source, toOffset: destination)
    }
}

//

struct CreateMethodInstructionStepView: View {

    let step: RecipeInstructionStepItem

    var instructionAction: InstructionAction? {
        step.recipeInstructionStep?.instructionAction
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(instructionAction?.message ?? "")
                .foregroundColor(Color("foregroundPrimary"))
                .padding(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .backgroundSecondary()
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}


#Preview {
    CreateMethodInstructionsView(viewModel: CreateMethodInstructionsViewModel())
}

struct CreateMethodInstructionsView: View {
    @EnvironmentObject var context: CreateMethodContext
    @ObservedObject var viewModel: CreateMethodInstructionsViewModel

    var body: some View {
        List {
            ForEach(viewModel.instructions) { instruction in
                CreateMethodInstructionStepView(step: instruction)
                    .onTapGesture {
                        debugPrint("Handle tap here") // TODO: handle tap action
                    }
            }
            .onDelete(perform: viewModel.removeInstruction)
            .onMove(perform: viewModel.moveInstruction)
        }
        .toolbar {
            EditButton()
        }
    }
}

#Preview {
    CreateMethodInstructionsView(viewModel: CreateMethodInstructionsViewModel())
}
