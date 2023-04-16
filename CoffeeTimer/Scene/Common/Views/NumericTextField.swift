//
//  NumericTextField.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

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

struct NumericTextField_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			Spacer()
			NumericTextField(placeholder: "placeholder", input: .constant(2.0)) { _ in }
				.padding()
			Spacer()
		}
		.background(Color.black)
    }
}
