//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

final class CreateMethodContext: ObservableObject {
    @Published var selectedMethod: BrewMethod?
    @Published var allMethods: [BrewMethod] = []

    @Published var methodTitle: String = ""

    var cupsCount: CupsCount {
        CupsCount(
            minimum: cupsCountMin > 0 ? Int(cupsCountMin) : 1,
            maximum: cupsCountMax > 0 ? Int(cupsCountMax) : nil
        )
    }
    @Published var cupsCountMin: Double = 0
    @Published var cupsCountMax: Double = 0

    @Published var isIcedBrew: Bool = false

    @Published var instructions: [RecipeInstructionStepItem] = []
}

//

final class CreateMethodViewModel: ObservableObject {
    @Published var selectedPage = 1
}

struct CreateMethodView: View {
    @ObservedObject var viewModel: CreateMethodViewModel
    var closeRequest: () -> Void

    var body: some View {
        VStack {

            HStack {
                Button("Close", action: closeRequest)
                    .frame(alignment: .topLeading)

                Spacer()
            }
            .padding()
            .foregroundColor(Color("backgroundSecondary"))

            TabView(selection: $viewModel.selectedPage) {
                CreateMethodDetailsView()
                    .tag(1)

                CreateMethodInstructionsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .backgroundPrimary()
    }
}

#Preview {
    CreateMethodView(viewModel: CreateMethodViewModel(), closeRequest: { })
        .environmentObject(stubContext())
}

fileprivate func stubContext() -> CreateMethodContext {
    let context = CreateMethodContext()
    context.instructions = .stub
    return context
}
