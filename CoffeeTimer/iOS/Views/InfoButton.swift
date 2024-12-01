//
//  InfoButton.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/11/2024.
//

import SwiftUI

struct InfoButton: View {
    @State private var isInfoPresented = false

    let infoModel: InfoModel

    var body: some View {
        Button {
            isInfoPresented = true
        } label: {
            Image(systemName: "info.circle")
        }
        .popover(isPresented: $isInfoPresented) {
            InfoView(model: infoModel)
        }
    }
}
