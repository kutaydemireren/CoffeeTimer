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

    // Picked once, so the copy stays the same while the screen re-renders.
    private(set) lazy var header: StageHeader = .init(
        title: titles.randomElement() ?? titles[0],
        subtext: subtitles.randomElement() ?? subtitles[0]
    )

    private let ctaTexts = [
        "Love CoffeeTimer? Let me know by sharing a cup!",
        "Enjoyed using CoffeeTimer?",
        "If CoffeeTimer made your day better, share a cup with me!",
        "Like CoffeeTimer? Your support helps me keep crafting.",
        "CoffeeTimer is made with love, and your support keeps me inspired."
    ]
    private(set) lazy var cta: String = ctaTexts.randomElement() ?? ctaTexts[0]

    let animation: String = "post-brew-\([1, 2, 3].randomElement() ?? 1)"
}

struct PostBrewView: View {
    var confirm: () -> Void
    var dismiss: () -> Void
    /// "Tweak this brew"; hidden when `nil`.
    var tweak: (() -> Void)? = nil

    @State private var viewModel = PostBrewViewModel()

    var body: some View {
        BuyMeACoffeeView(
            viewModel: viewModel,
            confirm: confirm,
            dismiss: dismiss,
            secondaryAction: tweak.map { BuyMeACoffeeSecondaryAction(title: "Tweak this brew", action: $0) }
        )
    }
}

#Preview {
    PostBrewView(
        confirm: { },
        dismiss: { },
        tweak: { }
    )
}
