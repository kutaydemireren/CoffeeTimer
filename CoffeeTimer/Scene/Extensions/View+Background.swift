//
//  View+Background.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct BackgroundPrimary: ViewModifier {
	func body(content: Content) -> some View {
		content
			.background(
				Rectangle()
					.fill(Gradient(colors: [.indigo, Color.black]))
					.ignoresSafeArea()
			)
	}
}

extension View {
	func backgroundPrimary() -> some View {
		modifier(BackgroundPrimary())
	}
}
