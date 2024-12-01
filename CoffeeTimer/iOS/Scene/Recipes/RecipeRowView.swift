//
//  RecipeRowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 10/05/2023.
//

import SwiftUI

struct RecipeProfileView: View {
    let alignment: HorizontalAlignment
    let recipeProfile: RecipeProfile

    var body: some View {
        VStack(alignment: alignment) {
            Text(recipeProfile.name)
                .foregroundColor(Color("foregroundPrimary"))
                .bold()

            Text("(\(recipeProfile.brewMethod.title))")
                .foregroundColor(Color("foregroundSecondary"))
        }
    }
}

struct RecipeProfileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RecipeProfileView(alignment: .leading, recipeProfile: .stubSingleV60)
        }
        .background(Color.orange)
    }
}


struct RecipeRowView: View {
    let recipe: Recipe
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading) {
            RecipeProfileView(alignment: .leading, recipeProfile: recipe.recipeProfile)
            Text(recipe.ingredients.toRepresentableString)
                .foregroundColor(Color("foregroundPrimary"))
                .padding(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal)
        .backgroundSecondary(opacity: isSelected ? 0.8 : 0.5)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

struct RecipeRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RecipeRowView(recipe: .stubSingleV60, isSelected: false)
        }
        .frame(height: 125)
    }
}
