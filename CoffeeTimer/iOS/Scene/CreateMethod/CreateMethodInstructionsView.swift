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
    func addNewInstruction(context: CreateMethodContext) {
        context.instructions.append(.init(action: .message(.init(message: "", details: ""))))
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
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel = CreateMethodInstructionsViewModel()

    var didSelect: ((RecipeInstructionActionItem) -> Void)?

    var body: some View {
        VStack {
            content
            addListActions
        }
    }

    @ViewBuilder
    private var addListActions: some View {
        VStack {

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
                .padding(.horizontal)
                .padding(.bottom)

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
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollViewReader { proxy in
            if #available(iOS 17.0, *) { // It is in the plan to upgrade to 17. Can simply remain without any fallback.
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
                .padding()
                .onChange(of: $context.instructions.map { $0.id }) { oldValue, newValue in
                    guard newValue.count > oldValue.count else { return }
                    withAnimation {
                        proxy.scrollTo(newValue.last)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

    private func didInstructionsChange(oldValue: RecipeInstructionActionItem, newValue: RecipeInstructionActionItem) {

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
