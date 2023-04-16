//
//  AlphanumericTextField.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct AlphanumericTextField: View {

	var placeholder: String
	@Binding var text: String

	var body: some View {
		TextField(text: $text) {
			Text(placeholder)
				.foregroundColor(.white.opacity(0.3))
		}
		.textFieldStyle(.plain)
		.foregroundColor(.white)
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 24)
				.fill(
					LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
				)
		)
	}
}

struct AlphanumericTextField_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			Spacer()
			AlphanumericTextField(placeholder: "placeholder", text: .constant(""))
				.padding()
			Spacer()
		}
		.background(Color.black)
    }
}