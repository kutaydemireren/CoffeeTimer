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
            .tabViewStyle(.page)
            .ignoresSafeArea(.keyboard)
        }
        .backgroundPrimary()
    }

    @ViewBuilder
    private func header() -> some View {
        if canCreate {
            ScreenHeaderView(close: close, primaryTitle: "Save") {
                Task {
                    try await create()
                    close()
                }
            }
        } else {
            ScreenHeaderView(close: close, primaryTitle: "Next") {
                withAnimation { nextPage() }
            }
        }
    }
}

/// The app's screen header: Close on the leading side, one action (Next, Save) on the trailing side.
struct ScreenHeaderView: View {
    var closeTitle = "Close"
    var close: () -> Void
    var primaryTitle: String
    var primary: () -> Void

    var body: some View {
        HStack {
            Button(closeTitle, action: close)
                .frame(alignment: .topLeading)

            Spacer()

            Button(primaryTitle, action: primary)
        }
        .padding()
        .foregroundStyle(Color("backgroundSecondary"))
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
