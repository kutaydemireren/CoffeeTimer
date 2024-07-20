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
}

struct CreateMethodView: View {

    @EnvironmentObject var context: CreateMethodContext

    var body: some View {
        VStack {
            TitledPicker(
                selectedItem: $context.selectedMethod,
                allItems: $context.allMethods,
                title: "Choose a method",
                placeholder: "Custom"
            )

            if context.selectedMethod == nil {
                methodInputs
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    var methodInputs: some View {
        VStack {
            AlphanumericTextField(
                title: "Title will be used to display within app",
                placeholder: "My V60, Icy V60",
                text: $context.methodTitle
            )

            TitledContent(title: "Cups Count Min - Max") {
                HStack {
                    VStack(spacing: 0) {
                        NumericTextField(
                            title: "",
                            placeholder: "1",
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
                            placeholder: "5",
                            keyboardType: .number,
                            range: .init(minimum: 0),
                            input: $context.cupsCountMax
                        )
                        Text("0 = no limit")
                            .font(.footnote)
                    }
                }
            }

            TitledContent(title: "") {
                HStack(alignment: .center) {
                    Spacer()
                    Toggle(context.isIcedBrew ? "Iced brew" : "Hot brew", isOn: $context.isIcedBrew)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    CreateMethodView()
        .environmentObject(CreateMethodContext())
}
