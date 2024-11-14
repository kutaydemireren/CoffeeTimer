//
//  CreateMethodDetailsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

private extension BrewMethod {
    static var custom: BrewMethod {
        return BrewMethod(
            id: "custom-method",
            title: "Custom",
            path: "",
            isIcedBrew: false,
            cupsCount: .init(minimum: 1, maximum: 5),
            ratios: [
                .ratio17,
                .ratio18,
                .ratio20
            ]
        )
    }
}

@MainActor
final class CreateMethodDetailsViewModel: ObservableObject {
    @Published var allMethods: [BrewMethod] = []
    
    private let getBrewMethodsUseCase: GetBrewMethodsUseCase
    
    init(
        getBrewMethodsUseCase: GetBrewMethodsUseCase = GetBrewMethodsUseCaseImp()
    ) {
        self.getBrewMethodsUseCase = getBrewMethodsUseCase
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
}

struct CreateMethodDetailsView: View {
    @EnvironmentObject var context: CreateMethodContext
    @ObservedObject var viewModel = CreateMethodDetailsViewModel()

    var body: some View {
        VStack {
            TitledPicker(
                selectedItem: $context.selectedMethod,
                allItems: $viewModel.allMethods,
                title: "Choose a template to start with",
                placeholder: "Custom"
            )

            methodInputs

            Spacer()
        }
        .onAppear() {
            if context.selectedMethod == nil {
                context.selectedMethod = .custom
            }
        }
        .padding()
    }

    @ViewBuilder
    var methodInputs: some View {
        VStack {
            AlphanumericTextField(
                title: "Title",
                placeholder: "My V60, Icy V60",
                text: $context.methodTitle
            )

            TitledContent(title: "Cups Count") {
                HStack {
                    VStack(spacing: 0) {
                        NumericTextField(
                            title: "",
                            placeholder: "min",
                            keyboardType: .number,
                            range: .init(minimum: 1),
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
                            range: .init(minimum: 0),
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
        .environmentObject(CreateMethodContext())
}
