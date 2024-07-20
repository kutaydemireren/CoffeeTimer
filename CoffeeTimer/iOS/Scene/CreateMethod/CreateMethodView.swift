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

struct CreateMethodView: View {
    var body: some View {
        VStack {
            CreateMethodDetailsView()
        }
    }
}

#Preview {
    CreateMethodView()
        .environmentObject(CreateMethodContext())
}
