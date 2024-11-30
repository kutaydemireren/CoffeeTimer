//
//  InfoView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/11/2024.
//

import SwiftUI

struct InfoViewModel {
    let title: String
    let source: String?
    let body: String

    init(title: String, source: String? = nil, body: String) {
        self.title = title
        self.source = source
        self.body = body
    }
}

struct InfoView: View {
    let viewModel: InfoViewModel

    var body: some View {
        VStack {
            Text(viewModel.title)
                .bold()

            if let source = viewModel.source {
                Text(source)
                    .italic()
            }

            Spacer()

            Text(viewModel.body)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    InfoView(
        viewModel: .init(
            title: "Title",
            source: "by Kutay Demireren",
            body: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam dignissim diam vitae ex mollis consectetur. Sed elit ipsum, fermentum non urna sit amet, fermentum bibendum purus. Nunc condimentum enim nec lacinia tristique. Duis ac blandit massa. Sed auctor purus augue, vitae fringilla nibh venenatis scelerisque. Aliquam id mattis tortor. Duis eget enim quis orci consequat venenatis.
"""
        )
    )
}
