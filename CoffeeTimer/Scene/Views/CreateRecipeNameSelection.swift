//
//  CreateRecipeNameSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct CreateRecipeNameSelection: View {

	@Binding var recipeName: String

	var body: some View {
		VStack {
			Spacer()

			HStack {
				Spacer()

				TextField(text: $recipeName) {
					Text("Name your recipe: (V60 Magic)")
						.foregroundColor(.white.opacity(0.3))
				}
				.textFieldStyle(.plain)
				.multilineTextAlignment(.center)
				.foregroundColor(.white.opacity(0.8))

				Spacer()
			}

			Spacer()
		}
		.padding(.horizontal)
		.contentShape(Rectangle())
		.onTapGesture {
			hideKeyboard()
		}
	}
}

struct CreateRecipeNameSelection_Previews: PreviewProvider {
    static var previews: some View {
		CreateRecipeNameSelection(recipeName: .constant(""))
			.backgroundPrimary()
    }
}
