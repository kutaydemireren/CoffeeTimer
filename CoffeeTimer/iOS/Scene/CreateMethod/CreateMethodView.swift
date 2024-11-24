//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

final class CreateMethodContext: ObservableObject {
    @Published var selectedMethod: BrewMethod?

    @Published var methodTitle: String = ""

    var cupsCount: CupsCount {
        CupsCount(
            minimum: cupsCountMin > 0 ? Int(cupsCountMin) : 1,
            maximum: cupsCountMax > 0 ? Int(cupsCountMax) : nil
        )
    }
    @Published var cupsCountMin: Double = 0
    @Published var cupsCountMax: Double = 0

    @Published var instructions: [RecipeInstructionActionItem] = []
}

//

import Combine

final class CreateMethodViewModel: ObservableObject {
    private let pageCount = 2

    @Published var selectedPage = 1
    // TODO: `canCreate` is not properly handled atm!
    // check if user can create upon each update to data model
    @Published var canCreate: Bool = false

    func nextPage() {
        selectedPage = (selectedPage % pageCount) + 1
    }
}

struct CreateMethodView: View {
    @StateObject var viewModel: CreateMethodViewModel
    var close: () -> Void
    var selectItem: (RecipeInstructionActionItem) -> Void

    var body: some View {
        VStack {

            HStack {
                Button("Close", action: close)
                    .frame(alignment: .topLeading)

                Spacer()

                // TODO: update `next` | `save` to align with CreateRecipe
                // aka, show 'next' if not 'save'able, ow/ show `save`
                if viewModel.canCreate {
                    Button("Save") {
                        // TODO: 'save' functionality missing
                        close()
                    }
                } else {
                    Button("Next") {
                        withAnimation { viewModel.nextPage() }
                    }
                }
            }
            .padding()
            .foregroundColor(Color("backgroundSecondary"))

            TabView(selection: $viewModel.selectedPage) {
                CreateMethodDetailsView()
                    .tag(1)

                CreateMethodInstructionsView(didSelect: selectItem)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .backgroundPrimary()
    }
}

#Preview {
    CreateMethodView(
        viewModel: CreateMethodViewModel(),
        close: { },
        selectItem: { _ in }
    )
    .environmentObject(stubContext())
}

fileprivate func stubContext() -> CreateMethodContext {
    let context = CreateMethodContext()
    context.instructions = .stub
    return context
}
