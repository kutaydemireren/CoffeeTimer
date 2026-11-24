//
//  StepPaletteView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// The step kinds, in the user's words, as small tiles styled like the method tiles.
struct StepPaletteView: View {
    var select: (MethodStepKind) -> Void

    @State private var isShowingMore = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Add a step")
                    .font(.title3)
                    .foregroundStyle(Color("foregroundPrimary"))
                    .padding(.top, 24)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(MethodStepKind.common) { kind in
                        tile(kind)
                    }

                    if !isShowingMore {
                        Button {
                            withAnimation { isShowingMore = true }
                        } label: {
                            StepKindTile(title: "More", systemImage: "ellipsis")
                        }
                        .buttonStyle(.plain)
                    }

                    if isShowingMore {
                        ForEach(MethodStepKind.more) { kind in
                            tile(kind)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .backgroundPrimary()
    }

    private func tile(_ kind: MethodStepKind) -> some View {
        Button {
            select(kind)
        } label: {
            StepKindTile(title: kind.title, systemImage: kind.systemImage)
        }
        .buttonStyle(.plain)
    }
}

struct StepKindTile: View {
    let title: String
    let systemImage: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("backgroundSecondary").opacity(0.4))

            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
            .padding(8)
        }
        .frame(height: 90)
        .foregroundStyle(Color("foregroundPrimary"))
    }
}

#Preview {
    StepPaletteView(select: { _ in })
}
