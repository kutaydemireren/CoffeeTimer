//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

struct CreateMethodView: View {

    @Binding var selectedMethod: BrewMethod?
    @Binding var allMethods: [BrewMethod]

    var body: some View {
        VStack {
            TitledPicker(
                selectedItem: $selectedMethod,
                allItems: $allMethods,
                title: "Choose a method",
                placeholder: "Custom"
            )

            Spacer()
        }
    }
}

#Preview {
    CreateMethodView(
        selectedMethod: .constant(nil),
        allMethods: .constant([.v60Iced, .v60Single, .frenchPress])
    )
}
