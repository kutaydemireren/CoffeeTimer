//
//  PagerView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 26/11/2024.
//

import SwiftUI

//

/**
 Displays the content within app's pager view.
 */
struct PagerView<Content: View>: View {
    @Binding var selectedPage: Int
    @Binding var canCreate: Bool

    var close: () -> Void
    var create: () async throws -> Void
    var nextPage: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            header()

            TabView(selection: $selectedPage) {
                content()
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .ignoresSafeArea()
        }
        .backgroundPrimary()
    }

    @ViewBuilder
    private func header() -> some View {
        HStack {
            Button("Close", action: close)
                .frame(alignment: .topLeading)

            Spacer()

            if canCreate {
                Button("Save") {
                    Task {
                        try await create()
                        close()
                    }
                }
            } else {
                Button("Next") {
                    withAnimation { nextPage() }
                }
            }
        }
        .padding()
        .foregroundColor(Color("backgroundSecondary"))
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedPage = 1

        var body: some View {
            PagerView(
                selectedPage: $selectedPage,
                canCreate: .constant(false),
                close: { },
                create: { },
                nextPage: { },
                content: {
                    ZStack {
                        Text("It's a sunny day! ☀️")
                    }
                    .tag(1)

                    ZStack {
                        Text("It's a rainy day! 🌧️")
                    }
                    .tag(2)

                    ZStack {
                        Text("There is storm! 🌩️")
                    }
                    .tag(3)
                }
            )
        }
    }

    return PreviewWrapper()
}
