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

        VStack(spacing: 16) {

            HStack {
                Text(title)
            }
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)

            content()
        }
        .foregroundColor(Color("foregroundPrimary"))
        .padding()
        .backgroundSecondary()
    }
}

#Preview {
    VStack {
        Spacer()

        TitledContent(title: "Some Title") {
            VStack {
                Text("first text as content")
                Text("second text as content")
            }
        }

        Spacer()

        TitledContent(title: "Some Title") {
            VStack {
                Text("text as content")
                Text("text as content")
            }
        }

        Spacer()
    }
}

// TODO: move
extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }
}
