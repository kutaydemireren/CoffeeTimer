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
    }

    @ViewBuilder
    var methodInputs: some View {
        VStack {
            AlphanumericTextField(
                title: "Give a name to your method",
                placeholder: "My V60, Icy V60",
                text: $methodTitle
            )
        }
    }
}

#Preview {
    CreateMethodView(
        selectedMethod: .constant(nil),
        allMethods: .constant([.v60Iced, .v60Single, .frenchPress]), 
        methodTitle: .constant("")
    )
}
