//
//  CreateRecipeProfileSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

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
							.padding(12)
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

	static let gridCache = GridCache(title: TitleStorage.randomFunTitle, recipeProfileIcons: ProfileIconStorage.recipeProfileIcons)
}
