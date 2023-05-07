//
//  CreateRecipeProfileSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct RecipeProfileView: View {
	let recipeProfile: RecipeProfile
	var isSelected = false

	var body: some View {
		if let image = recipeProfile.image {
			VStack {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fill)
			}
			.padding(12)
			.foregroundColor(.white.opacity(0.8))
			.background {
				Circle()
					.fill(Color(recipeProfile.color.withAlphaComponent(isSelected ? 0.8 : 0.4)))
			}
		}
	}
}

struct RecipeProfile: Identifiable, Equatable {
	let id = UUID()
	let title: String
	let color: UIColor
	let image: UIImage?

	init(title: String, color: UIColor) {
		self.title = title
		self.color = color
		self.image = UIImage(named: "recipe-profile-\(title)")
	}
}

// TODO: Obviously, temp
extension MockStore {
	static var recipeProfiles: [RecipeProfile] {
		[
			RecipeProfile(title: "planet", color: .magenta),
			RecipeProfile(title: "moon", color: .brown),
			RecipeProfile(title: "nuclear", color: .orange),
			RecipeProfile(title: "planet", color: .magenta),
			RecipeProfile(title: "moon", color: .brown),
			RecipeProfile(title: "nuclear", color: .orange),
			RecipeProfile(title: "planet", color: .magenta),
			RecipeProfile(title: "moon", color: .brown),
			RecipeProfile(title: "nuclear", color: .orange),
			RecipeProfile(title: "planet", color: .magenta),
			RecipeProfile(title: "moon", color: .brown),
			RecipeProfile(title: "nuclear", color: .orange),
			RecipeProfile(title: "nuclear", color: .orange),
			RecipeProfile(title: "rocket", color: .purple),
			RecipeProfile(title: "rocket", color: .purple),
			RecipeProfile(title: "rocket", color: .purple)
		].shuffled()
	}
}

// TODO: Obviously, temp
struct MockTitleStorage {
	static let funTitles = [
		"Icons are the new socks - impossible to match.",
		"Icons are the ultimate indecision enablers.",
		"Icons: so many choices, so little time.",
		"Icons: small graphics, big headaches.",
		"Choosing an icon: the struggle is real.",
		"Choosing an icon: where art and indecision collide.",
		"Tiny pictures, big decisions.",
		"Simple yet so complicated.",
		"Small but mighty frustrating."
	]

	static var randomTitle: String {
		funTitles.randomElement() ?? ""
	}
}

extension Alignment: CaseIterable {
	public static var allCases: [Alignment] {
		return [
			.top,
			.bottom,
			.bottomLeading,
			.bottomTrailing,
			.center,
			.centerFirstTextBaseline,
			.centerLastTextBaseline,
			.leadingFirstTextBaseline,
			.leadingLastTextBaseline,
			.leading,
			.topLeading,
			.topTrailing,
			.trailing,
			.trailingFirstTextBaseline,
			.trailingLastTextBaseline
		]
	}

	static var random: Alignment {
		allCases.randomElement()!
	}
}

extension CGFloat {
	static var randomPadding: Self {
		return CGFloat((16..<24).randomElement() ?? 0)
	}

	static var randomSize: Self {
		return CGFloat((50..<60).randomElement() ?? 0)
	}
}

class GridCache {
	let title: String
	let recipeProfiles: [RecipeProfile]

	var widths: [CGFloat] = []
	var heights: [CGFloat] = []
	var alignments: [Alignment] = []
	var offset1: [CGFloat] = []
	var offset2: [CGFloat] = []
	var rotations: [Angle] = []


	init(title: String, recipeProfiles: [RecipeProfile]) {
		self.title = title
		self.recipeProfiles = recipeProfiles

		setup()
	}

	private func setup() {
		(0..<recipeProfiles.count).forEach { index in
			widths.append(.randomSize)
			heights.append(.randomSize)
			alignments.append(.random)
			offset1.append(randomOffset())
			offset2.append(randomOffset())
			rotations.append(randomRotation())
		}
	}

	private func randomRotation() -> Angle {
		let degrees = Double.random(in: -30...30)
		return Angle(degrees: degrees)
	}

	private func randomOffset() -> CGFloat {
		let offset = CGFloat.random(in: -8...8)
		return offset
	}
}

struct CreateRecipeProfileSelection: View {

	@Binding var recipeName: String
	@Binding var selectedRecipeProfile: RecipeProfile?

	let columns: [GridItem] = [
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
	]

	var count: Int {
		gridCache.recipeProfiles.count
	}

	let gridCache: GridCache

	var body: some View {

		VStack {

			VStack {
				TitledContent(title: gridCache.title) {

					LazyVGrid(columns: columns, spacing: 16) {
						ForEach(0..<count, id: \.self) { index in

							RecipeProfileView(
								recipeProfile: gridCache.recipeProfiles[index],
								isSelected: selectedRecipeProfile == gridCache.recipeProfiles[index]
							)
							.padding(2)
							.frame(width: gridCache.widths[index], height: gridCache.heights[index], alignment: gridCache.alignments[index])
							.rotationEffect(gridCache.rotations[index])
							.offset(x: gridCache.offset1[index], y: gridCache.offset2[index])
							.onTapGesture {
								selectedRecipeProfile = gridCache.recipeProfiles[index]
							}
						}
					}
				}

				Separator()

				AlphanumericTextField(title: "Name your recipe", placeholder: "V60 Magic", text: $recipeName)
					.multilineTextAlignment(.center)
					.clearButton(text: $recipeName)
			}

			Spacer()
		}
		.padding(.horizontal, 32)
		.contentShape(Rectangle())
		.onTapGesture {
			hideKeyboard()
		}
	}
}

struct CreateRecipeProfileSelection_Previews: PreviewProvider {
	static var previews: some View {
		CreateRecipeProfileSelection(recipeName: .constant(""), selectedRecipeProfile: .constant(MockStore.recipeProfiles[0]), gridCache: gridCache)
			.backgroundPrimary()
	}

	static let gridCache = GridCache(title: MockTitleStorage.randomTitle, recipeProfiles: MockStore.recipeProfiles)
}
