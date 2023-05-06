//
//  CreateRecipeCoffeeWaterSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

struct CreateRecipeCoffeeWaterSelection: View {

	@Binding var cupsCountAmount: Double
	@Binding var waterAmount: Double
	@State private var ratio = CoffeeToWaterRatio.ratio16

	var body: some View {
		VStack {

			cupsCountField

			separator

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

	private var separator: some View {
		HStack {
			Spacer()
			Rectangle()
				.fill(Color.white.opacity(0.3))
				.frame(height: 1)
			Spacer()
		}
		.padding(.vertical)
	}

	private var picker: some View {

		TitledContent(title: "How strong would you like?") {
			Menu {
				Picker(selection: $ratio, label: EmptyView()) {
					ForEach(CoffeeToWaterRatio.allCases) { ratio in
						Text(ratio.toRepresentableString)
					}
				}
				.onChange(of: ratio, perform: didUpdate(ratio:))
			} label: {
				pickerLabel
			}
		}
	}

	private var pickerLabel: some View {
		Text(ratio.toRepresentableString)
			.foregroundColor(.white.opacity(0.8))
			.padding()
			.backgroundSecondary()
	}

	private func didUpdate(ratio: CoffeeToWaterRatio) {
		waterAmount = cupsCountAmount * ratio.value
	}
}

struct CreateRecipeCoffeeWaterSelection_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeCoffeeWaterSelection(
			cupsCountAmount: .constant(2.0),
			waterAmount: .constant(4.0)
		)
		.backgroundPrimary()
	}
}
