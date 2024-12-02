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

    var body: some View {
        LottieView {
            try await DotLottieFile.named(dotLottieFilename)
        }
    }
}

#Preview {
    AnimationView(dotLottieFilename: "chemex")
}
