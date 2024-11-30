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
    var infoContent: (() -> any View)?

    var body: some View {

        VStack(spacing: 16) {

            HStack {
                Text(title)

                if let infoContent {
                    InfoButton {
                        infoContent()
                    }
                }
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
        } infoContent: {
                VStack {
                    Text("longer text as content because the text is expected to be a bit more descriptive")
                    Spacer()
                    Text("can be even a whole another view of its own")
                        .backgroundSecondary()
                }
                .padding()
                .toAnyView()
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
