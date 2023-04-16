//
//  FlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/04/2023.
//


import Foundation
import Combine
import SwiftUI

// TODO: Move, obviously
// Keep in mind Clean!
protocol BrewQueueRepository: AnyObject {
	static var selectedRecipe: Recipe { get set }
}

final class BrewQueueRepositoryImp: BrewQueueRepository {
	// TODO: Temp
	// Think of persistence ways!
	static var selectedRecipe: Recipe = .stub
}

protocol Completable {
	var didRequestCreate: PassthroughSubject<Self, Never> { get }
}

protocol Navigable: AnyObject, Identifiable, Hashable {}

extension Navigable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

enum Screen: Hashable {

	case brewQueue
	case createRecipe
}

final class FlowViewModel: ObservableObject {

	var subscription = Set<AnyCancellable>()

	@Published var navigationPath: [Screen] = []
	@Published var isCreateRecipePresented = false

	func make1() -> BrewQueueViewModel {
		let viewModel = BrewQueueViewModel(brewQueue: BrewQueueRepositoryImp.selectedRecipe.brewQueue)
		viewModel.didRequestCreate
			.sink(receiveValue: didRequestCreate)
			.store(in: &subscription)
		return viewModel
	}

	private func didRequestCreate(viewModel: BrewQueueViewModel) {
		isCreateRecipePresented = true
	}
}

struct FlowView: View {

	@StateObject var viewModel: FlowViewModel

	var body: some View {
		NavigationStack(path: $viewModel.navigationPath) {
			VStack() {
				BrewQueueView(viewModel: viewModel.make1())
			}
			.navigationDestination(for: Screen.self) { screen in
				switch screen {
				case .brewQueue:
					brewQueue()
				case .createRecipe:
					createRecipe()
				}
			}
		}
		.textFieldStyle(RoundedBorderTextFieldStyle())
		.fullScreenCover(isPresented: $viewModel.isCreateRecipePresented) {
			ZStack {
				createRecipe()
			}
		}
	}

	func brewQueue() -> some View {
		BrewQueueView(viewModel: viewModel.make1())
	}

	func createRecipe() -> some View {
		CreateRecipeView(viewModel: CreateRecipeViewModel()) {
			viewModel.isCreateRecipePresented = false
		}
	}
}

struct FlowView_Previews: PreviewProvider {
	static var previews: some View {
		FlowView(viewModel: .init())
	}
}
