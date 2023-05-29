//
//  CreateRecipeProfileSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct RecipeProfileIconView: View {
	let recipeProfileIcon: RecipeProfileIcon
	var isSelected = false

	var body: some View {
		if !recipeProfileIcon.imageName.isEmpty {
			Image(recipeProfileIcon.imageName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding(12)
				.background {
					Group {
						if let colorHex = recipeProfileIcon.color,
						   let color = Color(hexString: colorHex) {
							Circle()
								.fill(color)
								.opacity(isSelected ? 0.8 : 0.4)
						}
					}
				}
		}
	}
}

struct RecipeProfileView: View {
	let recipeProfile: RecipeProfile

	var body: some View {
		HStack {
			RecipeProfileIconView(recipeProfileIcon: recipeProfile.icon, isSelected: true)
			Text(recipeProfile.name)
		}
		.frame(maxHeight: 55)
	}
}

extension RecipeProfile {
	func updating(name: String) -> RecipeProfile {
		return RecipeProfile(
			name: name,
			icon: icon
		)
	}

	func updating(icon: RecipeProfileIcon) -> RecipeProfile {
		return RecipeProfile(
			name: name,
			icon: icon
		)
	}
}

extension MockStore {
	static var recipeProfileIcons: [RecipeProfileIcon] {
		[
			RecipeProfileIcon(title: "planet", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "planet 2", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon 2", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 2", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "planet 3", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon 3", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 3", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "planet 4", color: UIColor.magenta.hexString ?? ""),
			RecipeProfileIcon(title: "moon 4", color: UIColor.brown.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 4", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "nuclear 5 ", color: UIColor.orange.hexString ?? ""),
			RecipeProfileIcon(title: "rocket", color: UIColor.purple.hexString ?? ""),
			RecipeProfileIcon(title: "rocket 2", color: UIColor.purple.hexString ?? ""),
			RecipeProfileIcon(title: "rocket 3", color: UIColor.purple.hexString ?? "")
		].shuffled()
	}
}

// TODO: Temp
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
	let recipeProfileIcons: [RecipeProfileIcon]

	var widths: [CGFloat] = []
	var heights: [CGFloat] = []
	var alignments: [Alignment] = []
	var offsetX: [CGFloat] = []
	var offsetY: [CGFloat] = []
	var rotations: [Angle] = []


	init(title: String, recipeProfileIcons: [RecipeProfileIcon]) {
		self.title = title
		self.recipeProfileIcons = recipeProfileIcons

		setup()
	}

	private func setup() {
		(0..<recipeProfileIcons.count).forEach { index in
			widths.append(.randomSize)
			heights.append(.randomSize)
			alignments.append(.random)
			offsetX.append(randomOffset())
			offsetY.append(randomOffset())
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

	@Binding var recipeProfile: RecipeProfile

	let columns: [GridItem] = [
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
	]

	var count: Int {
		gridCache.recipeProfileIcons.count
	}

	let gridCache: GridCache

	private var nameWrapper: Binding<String> {
		.init(get: {
			self.recipeProfile.name
		}, set: { newValue in
			self.recipeProfile = recipeProfile.updating(name: newValue)
		})
	}

	var body: some View {

		VStack {

			VStack {
				TitledContent(title: gridCache.title) {

					LazyVGrid(columns: columns, spacing: 16) {
						ForEach(0..<count, id: \.self) { index in

							RecipeProfileIconView(
								recipeProfileIcon: gridCache.recipeProfileIcons[index],
								isSelected: recipeProfile.icon == gridCache.recipeProfileIcons[index]
							)
							.padding(2)
							.frame(width: gridCache.widths[index], height: gridCache.heights[index], alignment: gridCache.alignments[index])
							.rotationEffect(gridCache.rotations[index])
							.offset(x: gridCache.offsetX[index], y: gridCache.offsetY[index])
							.onTapGesture {
								recipeProfile = recipeProfile.updating(icon: gridCache.recipeProfileIcons[index])
							}
						}
					}
				}

				Separator()

				AlphanumericTextField(title: "Name your recipe", placeholder: "V60 Magic", text: nameWrapper)
					.multilineTextAlignment(.center)
					.clearButton(text: nameWrapper)
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
		CreateRecipeProfileSelection(recipeProfile: .constant(.empty), gridCache: gridCache)
			.backgroundPrimary()
	}

	static let gridCache = GridCache(title: MockTitleStorage.randomTitle, recipeProfileIcons: MockStore.recipeProfileIcons)
}
