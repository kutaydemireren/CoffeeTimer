//
//  AnalyticsTrackerImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren.
//

import Foundation

struct AnalyticsTrackerImp: AnalyticsTracker {
    private let firebaseTracker: FirebaseAnalyticsTracker
    
    init(firebaseTracker: FirebaseAnalyticsTracker = FirebaseAnalyticsTracker()) {
        self.firebaseTracker = firebaseTracker
    }
    
    func track(event: AnalyticsEvent) {
        firebaseTracker.logEvent(event.name, parameters: event.parameters)
    }
}

