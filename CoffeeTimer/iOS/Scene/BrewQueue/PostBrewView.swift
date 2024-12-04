//
//  PostBrewView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/12/2024.
//

import SwiftUI

final class PostBrewViewModel: BuyMeACoffeeViewModel {
    private let titles = [
        "Enjoy your brew!",
        "Brew-tiful job!",
        "The perfect cup awaits!",
        "Sip and savor!",
        "Perfect brew!"
    ]
    private let subtitles = [
        "Take a moment to enjoy the perfect cup you just brewed.",
        "Every great coffee starts with a great brew. Cheers!",
        "Hope this cup makes your day brighter!",
        "Crafted with care, just for you. Enjoy!",
        "Good coffee, good vibes. You’ve earned it!"
    ]

    private var title: String {
        titles.randomElement() ?? titles[0]
    }

    private var subtitle: String {
        subtitles.randomElement() ?? subtitles[0]
    }

    var header: StageHeader {
        .init(title: title, subtext: subtitle)
    }

    private let ctaTexts = [
        "Love CoffeeTimer? Let me know by sharing a cup!",
        "Enjoyed using CoffeeTimer?",
        "If CoffeeTimer made your day better, share a cup with me!",
        "Like CoffeeTimer? Your support helps me keep crafting.",
        "CoffeeTimer is made with love, and your support keeps me inspired."
    ]
    var cta: String {
        ctaTexts.randomElement() ?? ctaTexts[0]
    }

    var animation: String {
        "post-brew-\([1, 2, 3].randomElement() ?? 1)"
    }
}

struct PostBrewView: View {
    let viewModel = PostBrewViewModel()

    var dismiss: () -> Void

    var body: some View {
        BuyMeACoffeeView(
            viewModel: PostBrewViewModel(),
            confirm: { },
            dismiss: { }
        )
    }
}

#Preview {
    PostBrewView { }
}
