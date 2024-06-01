//
//  CreateRecipeBrewMethodSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct BrewMethodView: View {
    let brewMethod: BrewMethod
    
    var isSelected = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color("backgroundSecondary").opacity(0.8) : Color("backgroundSecondary").opacity(0.4))
                .overlay {
                    Text(brewMethod.title)
                        .foregroundColor(isSelected ? Color("foregroundPrimary") : Color("foregroundPrimary").opacity(0.8))
                        .font(.title2)
                }
        }
    }
}

struct CreateRecipeBrewMethodSelection: View {
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    let height: CGFloat = 150
    let brewMethods: [BrewMethod] = BrewMethodStorage.brewMethods
    
    @Binding var selectedBrewMethod: BrewMethod?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(brewMethods) { brewMethod in
                    BrewMethodView(
                        brewMethod: brewMethod,
                        isSelected: selectedBrewMethod == brewMethod
                    )
                    .frame(height: height)
                    .onTapGesture {
                        selectedBrewMethod = brewMethod
                    }
                }
            }
            .padding()
        }
    }
}

struct CreateRecipeBrewMethodSelection_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeBrewMethodSelection(selectedBrewMethod: .constant(.v60))
            .backgroundPrimary()
    }
}

// TODO: move to preview content
extension BrewMethod {
    static var v60: Self {
        return BrewMethod(id: "v60", title: "V60", path: "", ratios: CoffeeToWaterRatio.allCases)
    }
}
