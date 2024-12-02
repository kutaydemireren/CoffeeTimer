//
//  CreateMethodDetailsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

private var templateInfo: InfoModel {
    return .init(
        title: "Choose a Template",
        body: """
Selecting an existing brewing method will duplicate its instructions, so that you can adjust the steps to make it your own.

Simply select one of the options, and you can find the instructions duplicated in the next page.
"""
    )
}

private extension BrewMethod {
    static var custom: BrewMethod {
        return BrewMethod(
            id: "custom-method",
            iconName: "",
            title: "Custom",
            path: "",
            isIcedBrew: false,
            cupsCount: .init(minimum: 1, maximum: 5),
            ratios: [
                .ratio17,
                .ratio18,
                .ratio20
            ],
            info: .empty
        )
    }
}

@MainActor
final class CreateMethodDetailsViewModel: ObservableObject {
    @Published var allMethods: [BrewMethod] = []
    
    private let getBrewMethodsUseCase: GetBrewMethodsUseCase
    private let fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase
    
    init(
        getBrewMethodsUseCase: GetBrewMethodsUseCase = GetBrewMethodsUseCaseImp(),
        fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase = FetchRecipeInstructionsUseCaseImp()
    ) {
        self.getBrewMethodsUseCase = getBrewMethodsUseCase
        self.fetchRecipeInstructionsUseCase = fetchRecipeInstructionsUseCase
        refreshMethods()
    }

    func refreshMethods() {
        guard allMethods.isEmpty else { return }

        allMethods = [.custom]
        Task {
            let brewMethods = try await getBrewMethodsUseCase.getAll()
            allMethods.append(contentsOf: brewMethods)
        }
    }
    
    func didSelect(selectedMethod: BrewMethod, in context: CreateBrewMethodContext) {
        context.selectedMethod = selectedMethod
        Task {
            let instructions = try await fetchRecipeInstructionsUseCase.fetchActions(brewMethod: selectedMethod)
            context.instructions = instructions.map { .init(action: $0) }
        }
    }
}

struct CreateMethodDetailsView: View {
    @EnvironmentObject var context: CreateBrewMethodContext
    @ObservedObject var viewModel = CreateMethodDetailsViewModel()

    var body: some View {
        VStack {
            TitledPicker(
                selectedItem: $context.selectedMethod,
                allItems: $viewModel.allMethods,
                title: "Choose a template to start with",
                placeholder: "Custom",
                infoModel: templateInfo
            )

            methodInputs

            Spacer()
        }
        .onAppear() {
            if context.selectedMethod == nil {
                context.selectedMethod = .custom
            }
        }
        .onChange(of: context.selectedMethod, perform: didUpdate(_:))
        .padding()
        .hideKeyboardOnTap()
    }
    
    private func didUpdate(_ newMethod: BrewMethod?) {
        viewModel.didSelect(selectedMethod: newMethod ?? .custom, in: context)
    }

    @ViewBuilder
    var methodInputs: some View {
        VStack {
            AlphanumericTextField(
                text: $context.methodTitle,
                style: .titled("Title"),
                placeholder: "My V60, Icy V60"
            )

            TitledContent(title: "Cups Count") {
                HStack {
                    VStack(spacing: 0) {
                        NumericTextField(
                            title: "",
                            placeholder: "min",
                            keyboardType: .number,
                            range: .init(minimum: 1, maximum: 10),
                            input: $context.cupsCountMin
                        )
                        Text("") // this is (and VStack) needed to align with the neighbour content
                            .font(.footnote)
                    }
                    VStack(spacing: 0) {
                        NumericTextField(
                            title: "",
                            placeholder: "max",
                            keyboardType: .number,
                            range: .init(minimum: 0, maximum: 30),
                            input: $context.cupsCountMax
                        )
                        Text("0 = no limit")
                            .font(.footnote)
                    }
                }
            }
        }
    }
}

#Preview {
    CreateMethodDetailsView()
        .environmentObject(CreateBrewMethodContext())
}
