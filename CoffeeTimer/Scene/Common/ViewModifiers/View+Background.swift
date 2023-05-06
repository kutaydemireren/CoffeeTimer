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

struct BackgroundSecondary: ViewModifier {
	func body(content: Content) -> some View {
		content
			.background(
				RoundedRectangle(cornerRadius: 24)
					.fill(
						LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
					)
			)
	}
}

extension View {
	func backgroundPrimary() -> some View {
		modifier(BackgroundPrimary())
	}

	func backgroundSecondary() -> some View {
		modifier(BackgroundSecondary())
	}
}
