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

struct BuyMeACoffeeView<Model: BuyMeACoffeeViewModel>: View {
    let viewModel: Model
    let confirm: () -> Void
    let dismiss: () -> Void

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
                dismiss()
            } label: {
                Text("Buy Me a Coffee")
                    .font(.callout)
                    .padding(12)
                    .foregroundColor(Color("backgroundSecondary"))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color("backgroundPrimary"))
                    )
            }
            .padding(.bottom, 20)

            Button {
                dismiss()
            } label: {
                Text("Skip")
                    .font(.callout)
                    .padding(12)
                    .padding(.horizontal)
                    .overlay {
                        Capsule()
                            .stroke(Color("backgroundPrimary"), lineWidth: 2)
                    }
            }

            Spacer()
        }
        .padding()
        .foregroundColor(Color("backgroundPrimary"))
        .background {
            Color("backgroundSecondary")
                .ignoresSafeArea()
        }
    }
}

private class BuyMeACoffeePreviewViewModel: BuyMeACoffeeViewModel {
    let header: StageHeader = .init(title: "The Big Title", subtext: "Some other text in smaller fonts")
    let cta: String = "Some text supporting the CTA"
    let animation: String = "post-brew-1"
}

#Preview {
    BuyMeACoffeeView(
        viewModel: BuyMeACoffeePreviewViewModel(),
        confirm: { },
        dismiss: { }
    )
}
