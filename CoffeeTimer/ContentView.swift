//
//  ContentView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/02/2023.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		Circle()
			.strokeBorder(Color.blue.opacity(0.6), lineWidth: 4)
			.overlay {
				Text("00 : 00 : 00")
					.font(.largeTitle)
					.foregroundColor(.blue)
			}
			.padding(24)
			.background(Color.black.opacity(0.9))
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
