//
//  CreateRecipeCoffeeWaterSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

struct Separator: View {
    var body: some View {
        Rectangle()
            .fill(Color("foregroundPrimary").opacity(0.3))
            .frame(height: 1)
            .padding(.vertical)
    }
}

struct CreateRecipeCoffeeWaterSelection: View {
    
    @Binding var cupsCountAmount: Double
    @Binding var selectedRatio: CoffeeToWaterRatio?
    @Binding var allRatios: [CoffeeToWaterRatio]
    
    @EnvironmentObject var context: CreateRecipeContext
    
    var body: some View {
        VStack {
            
            cupsCountField
            
            Separator()
            
            picker
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
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
    
    private var picker: some View {
        
        TitledContent(title: "How strong would you like?") {
            Menu {
                Picker(selection: $selectedRatio, label: EmptyView()) {
                    ForEach(allRatios) { ratio in
                        Text(ratio.title)
                            .tag(ratio as CoffeeToWaterRatio?)
                    }
                }
            } label: {
                pickerLabel
            }
        }
    }
    
    private var pickerLabel: some View {
        Text(selectedRatio?.title ?? "Choose preferred ratio")
            .foregroundColor(Color("foregroundPrimary").opacity(0.8))
            .padding()
            .backgroundSecondary()
    }
}

struct CreateRecipeCoffeeWaterSelection_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeCoffeeWaterSelection(
            cupsCountAmount: .constant(2.0),
            selectedRatio: .constant(.ratio18),
            allRatios: .constant([.ratio16, .ratio17, .ratio18, .ratio20])
        )
        .backgroundPrimary()
        .environmentObject(CreateRecipeContext())
    }
}
