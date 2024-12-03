//
//  AnimationView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/12/2024.
//

import SwiftUI
import Lottie

/// Currently only ".lottie" files are supported.
struct AnimationView: View {
    let dotLottieFilename: String
    var loop: Bool = true

    var body: some View {
        LottieView {
            try await DotLottieFile.named(dotLottieFilename)
        }
        .playing(loopMode: loop ? .loop : .playOnce)
    }
}

#Preview {
    AnimationView(dotLottieFilename: "v60")
}
