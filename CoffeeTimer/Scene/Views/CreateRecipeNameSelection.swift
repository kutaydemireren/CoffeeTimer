//
//  CreateRecipeNameSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct CreateRecipeNameSelection: View {

	@State private var recipeName: String = ""
	var showNext: () -> Void

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
				.foregroundColor(.white.opacity(0.8))

				Spacer()
			}

			Button("Next") {
				showNext()
			}
			.foregroundColor(.white)

			Spacer()
		}
		.padding(.horizontal)
		.background(
			Rectangle()
				.fill(Gradient(colors: [.indigo, Color.black]))
				.ignoresSafeArea()
		)
		.onTapGesture {
			hideKeyboard()

		}
	}
}

struct CreateRecipeNameSelection_Previews: PreviewProvider {
    static var previews: some View {
		CreateRecipeNameSelection { }
    }
}
