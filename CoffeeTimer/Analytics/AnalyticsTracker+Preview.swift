//
//  AnalyticsTracker+Preview.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren.
//

import Foundation

#if DEBUG
/// No-op implementation for SwiftUI previews
struct PreviewAnalyticsTracker: AnalyticsTracker {
    func track(event: AnalyticsEvent) {
        // No-op: intentionally does nothing for previews
    }
}
#endif

