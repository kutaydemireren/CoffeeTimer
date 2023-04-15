//
//  FlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 11/04/2023.
//


import Foundation
import Combine
import SwiftUI

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

final class FlowVM: ObservableObject {

	var subscription = Set<AnyCancellable>()

	@Published var navigationPath: [Screen] = []
	@Published var showingSheet = false

	init() {
	}

	func make1() -> BrewQueueViewModel {
		let vm = BrewQueueViewModel(brewQueue: .stub)
		vm.didRequestCreate
			.sink(receiveValue: didRequestCreate)
			.store(in: &subscription)
		return vm
	}

	private func didRequestCreate(vm: BrewQueueViewModel) {
		navigationPath.append(.createRecipe)
//		showingSheet = true
	}
}

struct FlowView: View {

	@StateObject var vm: FlowVM

	var body: some View {
		NavigationStack(path: $vm.navigationPath) {
			VStack() {
				BrewQueueView(viewModel: vm.make1())
			}
			.navigationDestination(for: Screen.self) { screen in
				switch screen {
				case .brewQueue:
					BrewQueueView(viewModel: vm.make1())
				case .createRecipe:
					CreateRecipeView()
				}
			}
		}
		.textFieldStyle(RoundedBorderTextFieldStyle())
		.fullScreenCover(isPresented: $vm.showingSheet) {
			CreateRecipeView()
		}
	}
}
