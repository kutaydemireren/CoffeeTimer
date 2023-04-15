//
//  CreateRecipeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 05/04/2023.
//

import SwiftUI
import Combine

extension FloatingPoint {
	var isInteger: Bool { rounded() == self }
}

extension View {
	func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}

struct NumericTextField: View {

	var placeholder: String
	@FocusState private var isFocused: Bool

	@Binding var input: Double

	@State private var displayText: String = ""

	var didUpdate: (Double) -> Void

	var body: some View {

		TextField(text: $displayText) {
			Text(placeholder)
				.foregroundColor(.white.opacity(0.5))
		}
		.textFieldStyle(.plain)
		.keyboardType(.decimalPad)
		.focused($isFocused)
		.foregroundColor(.white)
		.onChange(of: displayText, perform: filterNumerics(_:))
		.onChange(of: input, perform: setDisplayText(_:))
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(
					LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
				)
		)
		.padding()
	}

	private func filterNumerics(_ newValue: String) {

		guard isFocused else {
			return
		}

		var str = ""
		if Double(newValue) != nil {
			str = newValue
		} else {
			let trimmed = newValue.trimmingCharacters(in: CharacterSet(charactersIn: "."))
			str = trimmed.filter { "0123456789.".contains($0) }
		}
		displayText = str

		if let input = Double(displayText) {
			self.input = input
			didUpdate(input)
		}
	}

	private func setDisplayText(_ newValue: Double) {
		if Double(displayText) != newValue {
			displayText = "\(newValue)"
		}
	}
}

enum CoffeeToWaterRatio: String, CaseIterable, Identifiable {
	case ratio15 = "1:15"
	case ratio16 = "1:16"
	case ratio17 = "1:17"
	case ratio18 = "1:18"
	case ratio19 = "1:19"
	case ratio20 = "1:20"
	case ratio21 = "1:21"
	case ratio22 = "1:22"

	var id: Self { self }

	var value: Double {
		switch self {
		case .ratio15:
			return 15
		case .ratio16:
			return 16
		case .ratio17:
			return 17
		case .ratio18:
			return 18
		case .ratio19:
			return 19
		case .ratio20:
			return 20
		case .ratio21:
			return 21
		case .ratio22:
			return 22
		}
	}
}

struct CreateRecipeView: View {

	@State private var coffeeAmount = 0.0
	@State private var waterAmount = 0.0
	@State private var ratio = CoffeeToWaterRatio.ratio16

	var customLabel: some View {
		Text(ratio.rawValue)
			.foregroundColor(.white.opacity(0.8))
		.padding()
		.background(Color.white.opacity(0.1))
		.clipShape(Circle())
	}

	var body: some View {
		VStack {
			NumericTextField(
				placeholder: "Coffee amount",
				input: $coffeeAmount,
				didUpdate: { coffeeAmount in
					self.waterAmount = coffeeAmount * ratio.value
				}
			)

			HStack {
				Rectangle()
					.fill(Color.white.opacity(0.3))
					.frame(height: 1)

				Menu {
					Picker(ratio.rawValue, selection: $ratio) {
						ForEach(CoffeeToWaterRatio.allCases) { ratio in
							Text(ratio.rawValue)
						}
					}
					.onChange(of: ratio, perform: didUpdate(ratio:))
				} label: {
					customLabel
				}

				Rectangle()
					.fill(Color.white.opacity(0.3))
					.frame(height: 1)
			}
			.padding(.horizontal)

			NumericTextField(
				placeholder: "Water amount",
				input: $waterAmount,
				didUpdate: { waterAmount in
					self.coffeeAmount = waterAmount / ratio.value
				}
			)

			Spacer()
		}
		.padding(.horizontal)
		.background(
			Rectangle()
				.fill(Gradient(colors: [.indigo, Color.black]))
				.ignoresSafeArea()
		)
		.onTapGesture {
			self.hideKeyboard()
		}
	}

	private func didUpdate(ratio: CoffeeToWaterRatio) {
		waterAmount = coffeeAmount * ratio.value
	}
}

struct CreateRecipeView_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeView()
	}
}
