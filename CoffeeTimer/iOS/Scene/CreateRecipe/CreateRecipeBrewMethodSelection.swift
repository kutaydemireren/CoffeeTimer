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

    @Binding var brewMethods: [BrewMethod]
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
        CreateRecipeBrewMethodSelection(brewMethods: .constant([.frenchPress, .v60Single]), selectedBrewMethod: .constant(.v60Single))
            .backgroundPrimary()
    }
}

// TODO: move to preview content
extension BrewMethod {
    static var v60Single: Self {
        return BrewMethod(
            id: "v60-single",
            title: "V60 Single",
            path: "/v60-single", 
            isIcedBrew: false,
            cupsCount: .init(minimum: 1, maximum: 1),
            ratios: [
                .ratio16,
                .ratio18,
                .ratio20
            ]
        )
    }

    static var v60Iced: Self {
        return BrewMethod(
            id: "v60-iced",
            title: "V60 Iced",
            path: "/v60-iced",
            isIcedBrew: true,
            cupsCount: .unlimited,
            ratios: [
                .ratio16,
                .ratio17,
                .ratio18
            ]
        )
    }

    static var frenchPress: Self {
        return BrewMethod(
            id: "french-press",
            title: "French Press",
            path: "/french-press",
            isIcedBrew: false,
            cupsCount: .init(minimum: 1, maximum: 5),
            ratios: [
                .ratio17,
                .ratio18,
                .ratio20
            ]
        )
    }
}
