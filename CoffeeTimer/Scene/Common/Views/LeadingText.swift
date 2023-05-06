//
//  LeadingText.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import SwiftUI

struct LeadingText: View {
	let text: String

	init(_ text: String) {
		self.text = text
	}

	var body: some View {
		HStack {
			Text(text)
			Spacer()
		}
	}
}
