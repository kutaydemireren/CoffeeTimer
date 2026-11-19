//
//  View+ReviewPrompt.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/11/2026.
//

import SwiftUI
import StoreKit

/// Asks the system for a review once `trigger` is set and the screen has settled for `delay`.
/// The pending request is cancelled when the view disappears or `trigger` changes.
/// `confirm` runs right before the request: return `false` to skip it (e.g. a sheet is now on screen).
private struct ReviewPromptModifier: ViewModifier {
    @Environment(\.requestReview) private var requestReview

    let trigger: ReviewPromptTrigger?
    let delay: Duration
    let confirm: (ReviewPromptTrigger) -> Bool

    func body(content: Content) -> some View {
        content
            .task(id: trigger) {
                guard let trigger else { return }
                do {
                    try await Task.sleep(for: delay)
                } catch {
                    return
                }
                guard !Task.isCancelled, confirm(trigger) else { return }
                requestReview()
            }
    }
}

extension View {
    func reviewPrompt(
        trigger: ReviewPromptTrigger?,
        delay: Duration,
        confirm: @escaping (ReviewPromptTrigger) -> Bool
    ) -> some View {
        modifier(ReviewPromptModifier(trigger: trigger, delay: delay, confirm: confirm))
    }
}
