//
//  CreateMethodInstructionsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

// TODO: move
extension String {
    var dashIfEmpty: String {
        isEmpty ? "-" : self
    }
}

//

struct RecipeInstructionActionItemRowView: View {
    let item: RecipeInstructionActionItem

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(item.action.detailedTitle.dashIfEmpty)")
                .bold()
            Text("\(item.action.message.dashIfEmpty)")
        }
        .listRowSeparator(.hidden)
        .listRowBackground(
            BackgroundSecondary(opacity: 0.8)
        )
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

//

final class CreateMethodInstructionsViewModel: ObservableObject {
    func addNewInstruction(context: CreateBrewMethodContext) {
        context.instructions.append(.init(action: .message(.init(message: "", details: ""))))
    }

    func removeInstruction(at indexSet: IndexSet, context: CreateBrewMethodContext) {
        context.instructions.remove(atOffsets: indexSet)
    }

    func moveInstruction(from source: IndexSet, to destination: Int, context: CreateBrewMethodContext) {
        context.instructions.move(fromOffsets: source, toOffset: destination)
    }
}

//

struct CreateMethodInstructionsView: View {
    @EnvironmentObject var context: CreateBrewMethodContext
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel = CreateMethodInstructionsViewModel()
    @Binding var animateInstructions: Bool

    var didSelect: ((RecipeInstructionActionItem) -> Void)?

    var body: some View {
        ZStack {
            content
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    addListActions
                        .backgroundPrimary(opacity: 0.9)
                }
        }
    }

    @ViewBuilder
    private var addListActions: some View {
        HStack {

            Button {
                viewModel.addNewInstruction(context: context)
            } label: {
                HStack {
                    Image(uiImage: .add)
                        .renderingMode(.template)

                    Text("New Instruction")
                        .font(.callout)
                }
                .foregroundColor(Color("backgroundSecondary"))
            }
            .scaleEffect((animateInstructions && context.instructions.isEmpty) ? 1.1 : 1)
            .animation(
                Animation.default.repeatCount(1, autoreverses: true),
                value: animateInstructions
            )

            Spacer()

            Button {
                withAnimation {
                    editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
                }
            } label: {
                HStack {
                    Text(editMode?.wrappedValue == .active ? "Done" : "Edit List")
                        .font(.callout)
                        .animation(nil, value: editMode?.wrappedValue)

                    Image(systemName: "pencil")
                        .renderingMode(.template)
                }
                .foregroundColor(Color("backgroundSecondary"))
            }
        }
        .padding()
    }

    @ViewBuilder
    private var content: some View {
        ScrollViewReader { proxy in
            VStack {
                List {
                    ForEach($context.instructions) { instruction in
                        RecipeInstructionActionItemRowView(item: instruction.wrappedValue)
                            .onTapGesture {
                                didSelect?(instruction.wrappedValue)
                            }
                            .id(instruction.id)
                    }
                    .onDelete { viewModel.removeInstruction(at: $0, context: context) }
                    .onMove { viewModel.moveInstruction(from: $0, to: $1, context: context) }
                }
                .listStyle(.plain)
                .listRowSpacing(12)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
            }
            .onChange(of: $context.instructions.map { $0.id }) { oldValue, newValue in
                guard newValue.count > oldValue.count else { return }
                withAnimation {
                    proxy.scrollTo(newValue.last)
                }
            }
            .padding(.horizontal)
        }
    }

    private func didInstructionsChange(oldValue: RecipeInstructionActionItem, newValue: RecipeInstructionActionItem) {

    }
}

#if DEBUG
#Preview {
    previewWithContext
}

fileprivate var previewWithContext: some View {
    let context = CreateBrewMethodContext()
    context.instructions = .stub
    return CreateMethodInstructionsView(viewModel: CreateMethodInstructionsViewModel(), animateInstructions: .constant(false))
        .backgroundPrimary()
        .environmentObject(context)
}
#endif
