//
//  EditRecipeAmountsView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import SwiftUI

struct EditRecipeAmountsView: View {
    let recipe: Recipe
    var onSaved: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditRecipeAmountsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding()

            CreateRecipeCoffeeWaterSelection(
                cupsCountAmount: $viewModel.context.cupsCount,
                cupSizeAmount: $viewModel.context.cupSize,
                selectedRatio: $viewModel.context.ratio,
                allRatios: $viewModel.allRatios,
                animateCupsCount: nil,
                animateRatio: nil
            )
            .environmentObject(viewModel.context)

            footer
        }
        .ignoresSafeArea(.keyboard)
        .backgroundPrimary()
        .onAppear {
            viewModel.configure(with: recipe)
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Text("Edit Amounts")
                .font(.title3)
                .foregroundColor(Color("foregroundPrimary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .bold()
            }
            .padding()
            .foregroundColor(Color("foregroundPrimary").opacity(0.8))

            Spacer()

            Button {
                Task {
                    await viewModel.saveChanges()
                    onSaved?()
                    dismiss()
                }
            } label: {
                Text("Save")
                    .bold()
            }
            .padding()
            .foregroundColor(Color("foregroundPrimary"))
            .backgroundSecondary()
            .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

