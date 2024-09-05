//
//  CreateMethodDetailsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

struct CreateMethodDetailsView: View {
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
