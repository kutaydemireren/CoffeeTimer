//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

// TODO: move bindings into context
//struct CreateMethodContext {
//
//}

struct CreateMethodView: View {

//    @EnvironmentObject var context: CreateRecipeContext

    @Binding var selectedMethod: BrewMethod?
    @Binding var allMethods: [BrewMethod]

    @Binding var methodTitle: String

    @Binding var cupsCountLimitMin: Double
    @Binding var cupsCountLimitMax: Double

    var body: some View {
        VStack {
            TitledPicker(
                selectedItem: $selectedMethod,
                allItems: $allMethods,
                title: "Choose a method",
                placeholder: "Custom"
            )

            if selectedMethod == nil {
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
                text: $methodTitle
            )

            TitledContent(title: "Cups Count Min - Max") {
                HStack {
                    NumericTextField(
                        title: "",
                        placeholder: "1",
                        keyboardType: .number,
                        input: $cupsCountLimitMin
                    )
                    NumericTextField(
                        title: "",
                        placeholder: "5",
                        keyboardType: .number,
                        input: $cupsCountLimitMax
                    )
                }
            }
        }
    }
}

#Preview {
    CreateMethodView(
        selectedMethod: .constant(nil),
        allMethods: .constant([.v60Iced, .v60Single, .frenchPress]), 
        methodTitle: .constant(""),
        cupsCountLimitMin: .constant(1),
        cupsCountLimitMax: .constant(10)
    )
}
