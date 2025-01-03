//
//  CreateRecipeCoffeeWaterSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

struct CreateRecipeCoffeeWaterSelection: View {
    
    @Binding var cupsCountAmount: Double
    @Binding var cupSizeAmount: Double
    @Binding var selectedRatio: CoffeeToWaterRatio?
    @Binding var allRatios: [CoffeeToWaterRatio]
    
    @EnvironmentObject var context: CreateRecipeContext
    
    var body: some View {
        VStack {
            
            cupsCountField

            cupSizeField

            Separator()
                .padding(.vertical)

            ratioPicker
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .contentShape(Rectangle())
        .hideKeyboardOnTap()
    }
    
    private var cupsCountField: some View {
        NumericTextField(
            title: "How many cups are you brewing?",
            placeholder: "1",
            keyboardType: .number,
            range: .init(
                minimum: context.selectedBrewMethod?.cupsCount.minimum ?? 0,
                maximum: context.selectedBrewMethod?.cupsCount.maximum ?? .max
            ),
            input: $cupsCountAmount
        )
    }

    private var cupSizeField: some View {
        NumericTextField(
            title: "What is the size of each cup?",
            placeholder: "200",
            keyboardType: .number,
            input: $cupSizeAmount
        )
    }

    private var ratioPicker: some View {
        TitledPicker(
            selectedItem: $selectedRatio,
            allItems: $allRatios,
            title: "How strong would you like?",
            placeholder: "Choose a preferred ratio"
        )
    }
}

struct CreateRecipeCoffeeWaterSelection_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeCoffeeWaterSelection(
            cupsCountAmount: .constant(2.0),
            cupSizeAmount: .constant(200.0),
            selectedRatio: .constant(.ratio18),
            allRatios: .constant([.ratio16, .ratio17, .ratio18, .ratio20])
        )
        .backgroundPrimary()
        .environmentObject(CreateRecipeContext())
    }
}
