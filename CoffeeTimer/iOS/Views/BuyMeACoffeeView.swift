//
//  BuyMeACoffeeView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/12/2024.
//

import SwiftUI

protocol BuyMeACoffeeViewModel {
    var header: StageHeader { get }
    var cta: String { get }
    var animation: String { get }
}

/// A quiet extra button below the tip, styled like "Maybe next time!".
struct BuyMeACoffeeSecondaryAction {
    let title: String
    let action: () -> Void
}

struct BuyMeACoffeeView<Model: BuyMeACoffeeViewModel>: View {
    let viewModel: Model
    let confirm: () -> Void
    let dismiss: () -> Void
    var secondaryAction: BuyMeACoffeeSecondaryAction? = nil

    var body: some View {
        VStack {
            Spacer()

            StageHeaderView(
                header: viewModel.header,
                foregroundColor: Color("backgroundPrimary")
            )

            AnimationView(dotLottieFilename: viewModel.animation)

            Text(viewModel.cta)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .font(.callout)

            Button {
                confirm()
            } label: {
                Text("Buy Me a Coffee")
                    .bold()
                    .font(.callout)
                    .padding()
                    .foregroundStyle(Color("backgroundSecondary"))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color("backgroundPrimary"))
                    )
            }
            .padding(.bottom, 20)

            secondaryButton(title: "Maybe next time!", action: dismiss)

            if let secondaryAction {
                secondaryButton(title: secondaryAction.title, action: secondaryAction.action)
                    .padding(.top, 12)
            }

            Spacer()
        }
        .padding()
        .foregroundStyle(Color("backgroundPrimary"))
        .background {
            Color("backgroundSecondary")
                .ignoresSafeArea()
        }
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.callout)
                .padding(12)
                .overlay {
                    Capsule()
                        .stroke(Color("backgroundPrimary"), lineWidth: 2)
                }
        }
    }
}

private class BuyMeACoffeePreviewViewModel: BuyMeACoffeeViewModel {
    let header: StageHeader = .init(title: "The Big Title", subtext: "Some other text in smaller fonts")
    let cta: String = "Yet another text supporting the CTA"
    let animation: String = "post-brew-1"
}

#Preview {
    BuyMeACoffeeView(
        viewModel: BuyMeACoffeePreviewViewModel(),
        confirm: { },
        dismiss: { }
    )
}
