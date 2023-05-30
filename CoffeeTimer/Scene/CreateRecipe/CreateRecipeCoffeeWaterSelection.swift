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
	@Binding var ratio: CoffeeToWaterRatio

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
			input: $cupsCountAmount
		)
	}

	private var picker: some View {

		TitledContent(title: "How strong would you like?") {
			Menu {
				Picker(selection: $ratio, label: EmptyView()) {
					ForEach(CoffeeToWaterRatio.allCases) { ratio in
						Text(ratio.toRepresentableString)
					}
				}
			} label: {
				pickerLabel
			}
		}
	}

	private var pickerLabel: some View {
		Text(ratio.toRepresentableString)
			.foregroundColor(Color("foregroundPrimary").opacity(0.8))
			.padding()
			.backgroundSecondary()
	}
}

struct CreateRecipeCoffeeWaterSelection_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeCoffeeWaterSelection(
			cupsCountAmount: .constant(2.0),
			ratio: .constant(.ratio18)
		)
		.backgroundPrimary()
	}
}
