//
//  BrewGiftView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/12/2024.
//

import SwiftUI

final class BrewGiftViewModel: BuyMeACoffeeViewModel {
    private let subtitles = [
        "Love CoffeeTimer? Let me know by sharing a cup!",
        "Enjoyed using CoffeeTimer?",
        "If CoffeeTimer made your day better, share a cup with me!",
        "Like CoffeeTimer? Your support helps me keep crafting.",
        "CoffeeTimer is made with love, and your support keeps me inspired."
    ]

    private var subtitle: String {
        subtitles.randomElement() ?? subtitles[0]
    }

    var header: StageHeader {
        .init(subtext: subtitle)
    }

    let cta: String = ""

    var animation: String {
        "post-brew-\([1, 2, 3].randomElement() ?? 1)"
    }
}

struct BrewGiftView: View {
    var confirm: () -> Void
    var dismiss: () -> Void

    var body: some View {
        BuyMeACoffeeView(
            viewModel: BrewGiftViewModel(),
            confirm: confirm,
            dismiss: dismiss
        )
    }
}

#Preview {
    BrewGiftView(
        confirm: { },
        dismiss: { }
    )
}
