//
//  PauseInstructionActionView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

struct PauseInstructionActionView: View {
    /// The input and output source of the view
    @Binding var item: RecipeInstructionActionItem

    init?(item: Binding<RecipeInstructionActionItem>) {
        guard case .pause = item.wrappedValue.action else {
            return nil
        }
        _item = item
    }

    var body: some View {
        EmptyView()
//        VStack {
//            InstructionActionViewBuilder()
//                .with(requirement: .countdown)
//                .with(duration: $item.durationBinding())
//                .with(startMethod: .auto)
//                .with(skipMethod: .auto)
//                .with(message: $item.messageBinding())
//                .with(details: $item.detailsBinding())
//                .build()
//        }
    }
}
