//
//  Separator.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

// TODO: can be completely replaced with Divider 
struct Separator: View {
    var body: some View {
        Rectangle()
            .fill(Color("foregroundPrimary").opacity(0.3))
            .frame(height: 1)
    }
}
