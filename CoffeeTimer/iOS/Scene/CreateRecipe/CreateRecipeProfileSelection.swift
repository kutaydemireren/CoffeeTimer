//
//  CreateRecipeProfileSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

extension RecipeProfile {
    func updating(name: String) -> RecipeProfile {
        return RecipeProfile(
            name: name, 
            brewMethod: brewMethod
        )
    }
}

struct CreateRecipeProfileSelection: View {

    @Binding var recipeProfile: RecipeProfile

    private var nameWrapper: Binding<String> {
        .init(get: {
            self.recipeProfile.name
        }, set: { newValue in
            self.recipeProfile = recipeProfile.updating(name: newValue)
        })
    }

    var body: some View {

        VStack {
            VStack {
                AlphanumericTextField(title: "Name your recipe", placeholder: "V60 Magic", text: nameWrapper)
                    .multilineTextAlignment(.center)
                    .clearButton(text: nameWrapper)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct CreateRecipeProfileSelection_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeProfileSelection(recipeProfile: .constant(.empty))
            .backgroundPrimary()
    }
}
