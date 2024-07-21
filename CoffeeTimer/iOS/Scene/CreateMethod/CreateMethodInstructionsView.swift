//
//  CreateMethodInstructionsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

// TODO: move

struct RecipeInstructionStepItemView: View {
    let item: RecipeInstructionStepItem

    var body: some View {
        Text("Hello, \(String(describing: item.recipeInstructionStep?.instructionAction?.message))!")
    }
}

//

struct RecipeInstructionStepItem: Identifiable {
    let id = UUID()
    let recipeInstructionStep: RecipeInstructionStep?
}

//

extension Array where Element == RecipeInstructionStepItem {
    static var stub: Self {
        [
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
    }
}

//

struct RecipeInstructionStepItemRowView: View {
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
        .backgroundSecondary()
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

//

final class CreateMethodInstructionsViewModel: ObservableObject {
    func removeInstruction(at indexSet: IndexSet, context: CreateMethodContext) {
        context.instructions.remove(atOffsets: indexSet)
    }

    func moveInstruction(from source: IndexSet, to destination: Int, context: CreateMethodContext) {
        context.instructions.move(fromOffsets: source, toOffset: destination)
    }
}

//

struct CreateMethodInstructionsView: View {
    @EnvironmentObject var context: CreateMethodContext
    @ObservedObject var viewModel = CreateMethodInstructionsViewModel()

    var didSelect: ((RecipeInstructionStepItem) -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            content
        }
    }

    private var content: some View {
        VStack {
            List {
                ForEach($context.instructions) { instruction in
                    RecipeInstructionStepItemRowView(step: instruction.wrappedValue)
                        .onTapGesture {
                            didSelect?(instruction.wrappedValue)
                        }
                }
                .onDelete { viewModel.removeInstruction(at: $0, context: context) }
                .onMove{ viewModel.moveInstruction(from: $0, to: $1, context: context)}
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
        .padding()
    }
}

#Preview {
    previewWithContext
}

fileprivate var previewWithContext: some View {
    let context = CreateMethodContext()
    context.instructions = .stub
    return CreateMethodInstructionsView(viewModel: CreateMethodInstructionsViewModel())
        .environmentObject(context)
}
