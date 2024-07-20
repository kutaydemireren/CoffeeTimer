//
//  Separator.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

struct Separator: View {
    var body: some View {
        Rectangle()
            .fill(Color("foregroundPrimary").opacity(0.3))
            .frame(height: 1)
            .padding(.vertical)
    }
}
