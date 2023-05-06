//
//  TitledContent.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import SwiftUI

struct TitledContent<Content: View>: View {

	var title: String
	var content: () -> Content

	var body: some View {

		VStack(spacing: 24) {

			if !title.isEmpty {
				LeadingText(title)
					.font(.headline)
			}

			content()
		}
		.foregroundColor(.white)
		.padding()
		.backgroundSecondary()
	}
}
