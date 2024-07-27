//
//  CreateMethodInstructionsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

// TODO: move

extension Array where Element == RecipeInstructionActionItem {
    static var stub: Self {
        [
            .init(action: .put(.stub)),
            .init(action: .pause(.stub)),
            .init(action: .message(.stub)),
            .init(action: .put(.stub)),
        ]
    }
}

//

struct RecipeInstructionActionItemRowView: View {
    let step: RecipeInstructionActionItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(step.action.updatableMessage.message)
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
    func addNewInstruction(context: CreateMethodContext) {
        context.instructions.append(.init(action: .message(.init(message: "msg", details: ""))))

//            .append(.init(action: .message(.init(message: "", details: ""))))
    }

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

    var didSelect: ((RecipeInstructionActionItem) -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            content

            addNewButton
        }
    }

    @ViewBuilder
    private var addNewButton: some View {
        HStack {
            VStack {
                Spacer()

                Button {
                    viewModel.addNewInstruction(context: context)
                } label: {
                    HStack {
                        Image(uiImage: .add)
                            .renderingMode(.template)

                        Text("New Instruction")
                    }
                    .foregroundColor(Color("foregroundPrimary"))
                }
                .padding()
                .backgroundSecondary(opacity: 0.6)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack {
            List {
                ForEach($context.instructions) { instruction in
                    RecipeInstructionActionItemRowView(step: instruction.wrappedValue)
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
        .onAppear {
            debugPrint("----- start of CreateMethodInstructionsView")
            context.instructions.forEach { debugPrint($0.action.updatableMessage.message) }
            debugPrint("----- end CreateMethodInstructionsView -----")
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
