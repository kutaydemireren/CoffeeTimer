//
//  MethodStartChoiceView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// "Or, create your own": start from a method or from scratch, as two equal tiles.
/// "Start from a method" then shows the method grid to pick one from.
struct MethodStartChoiceView: View {
    let brewMethods: [BrewMethod]
    let draftName: String?
    var startFromScratch: () -> Void
    var startFrom: (BrewMethod) -> Void
    var continueDraft: () -> Void
    var close: () -> Void

    @State private var isPickingMethod = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(isPickingMethod ? "Back" : "Close") {
                    if isPickingMethod {
                        withAnimation { isPickingMethod = false }
                    } else {
                        close()
                    }
                }
                Spacer()
            }
            .padding()
            .foregroundStyle(Color("backgroundSecondary"))

            if isPickingMethod {
                methodGrid
                    .transition(.move(edge: .trailing))
            } else {
                choice
                    .transition(.move(edge: .leading))
            }
        }
        .backgroundPrimary()
    }

    private var choice: some View {
        VStack(spacing: 16) {
            Text("Create your own method")
                .font(.title3)
                .foregroundStyle(Color("foregroundPrimary"))

            if let draftName {
                Button(action: continueDraft) {
                    HStack {
                        Image(systemName: "doc.text")
                        VStack(alignment: .leading) {
                            Text("Continue your draft")
                                .bold()
                            Text(draftName.isEmpty ? "Untitled method" : draftName)
                                .font(.subheadline)
                                .foregroundStyle(Color("foregroundSecondary"))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .foregroundStyle(Color("foregroundPrimary"))
                    .backgroundSecondary(opacity: 0.6)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 16) {
                Button {
                    withAnimation { isPickingMethod = true }
                } label: {
                    StartTile(
                        iconName: "recipe-profile-v60",
                        title: "Start from a method",
                        subtitle: "Copy its steps, then change them"
                    )
                }
                .buttonStyle(.plain)

                Button(action: startFromScratch) {
                    StartTile(
                        iconName: MethodDraft.kettleIcon,
                        title: "Start from scratch",
                        subtitle: "Write each step yourself"
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(height: 220)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var methodGrid: some View {
        ScrollView {
            Text("Pick a method to start from")
                .font(.title3)
                .foregroundStyle(Color("foregroundPrimary"))

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(brewMethods) { brewMethod in
                    BrewMethodView(brewMethod: brewMethod)
                        .frame(height: 150)
                        .onTapGesture { startFrom(brewMethod) }
                        .accessibilityAddTraits(.isButton)
                }
            }
            .padding()
        }
    }
}

/// A large tile styled like `BrewMethodView`.
private struct StartTile: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("backgroundSecondary").opacity(0.4))

            VStack(spacing: 8) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 80, maxHeight: 80)

                Text(title)
                    .font(.title3)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("foregroundSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(12)
        }
        .foregroundStyle(Color("foregroundPrimary"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MethodStartChoiceView(
        brewMethods: [.v60Single, .frenchPress()],
        draftName: "My Kalita",
        startFromScratch: { },
        startFrom: { _ in },
        continueDraft: { },
        close: { }
    )
}
