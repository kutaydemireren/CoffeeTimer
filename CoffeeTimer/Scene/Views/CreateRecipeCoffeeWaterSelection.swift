//
//  CreateRecipeCoffeeWaterSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

struct CreateRecipeCoffeeWaterSelection: View {

	@State private var coffeeAmount = 0.0
	@State private var waterAmount = 0.0
	@State private var ratio = CoffeeToWaterRatio.ratio16

	var body: some View {
		VStack {

			coffeeTextField

			HStack {
				Rectangle()
					.fill(Color.white.opacity(0.3))
					.frame(height: 1)

				picker

				Rectangle()
					.fill(Color.white.opacity(0.3))
					.frame(height: 1)
			}
			.padding(.horizontal)

			waterTextField

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

	private var coffeeTextField: some View {
		NumericTextField(
			placeholder: "Coffee amount",
			input: $coffeeAmount,
			didUpdate: { coffeeAmount in
				self.waterAmount = coffeeAmount * ratio.value
			}
		)
	}

	private var picker: some View {
		Menu {
			Picker(selection: $ratio, label: EmptyView()) {
				ForEach(CoffeeToWaterRatio.allCases) { ratio in
					Text(ratio.rawValue)
				}
			}
			.onChange(of: ratio, perform: didUpdate(ratio:))
		} label: {
			pickerLabel
		}
	}

	private var pickerLabel: some View {
		Text(ratio.rawValue)
			.foregroundColor(.white.opacity(0.8))
			.padding()
			.background(Color.white.opacity(0.1))
			.clipShape(Circle())
	}

	private var waterTextField: some View {
		NumericTextField(
			placeholder: "Water amount",
			input: $waterAmount,
			didUpdate: { waterAmount in
				self.coffeeAmount = waterAmount / ratio.value
			}
		)
	}

	private func didUpdate(ratio: CoffeeToWaterRatio) {
		waterAmount = coffeeAmount * ratio.value
	}
}
struct CreateRecipeCoffeeWaterSelection_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeCoffeeWaterSelection()
    }
}
