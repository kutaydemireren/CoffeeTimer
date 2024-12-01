//
//  BrewQueueView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import SwiftUI
import Combine

extension Array where Element == Ingredient {
    var toRepresentableString: String {
        return map { "\($0.toRepresentableString)" }.joined(separator: "\n")
    }
}

extension Ingredient {
    var toRepresentableString: String {
        switch ingredientType {
        case .coffee:
            return "Coffee: \(amount.toRepresentableString)"
        case .water:
            return "Water: \(amount.toRepresentableString)"
        case .ice:
            return "Ice: \(amount.toRepresentableString)"
        }
    }
}

extension IngredientAmount {
    var toRepresentableString: String {
        switch type {
        case .gram:
            return "\(amount) g"
        case .millilitre:
            return "\(amount) ml"
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else {
            return nil
        }
        return self[index]
    }
}

extension String {
    struct BrewQueue {
        // TODO: rmv if not needed
        func stageHeader(for action: BrewStageAction) -> String {
            return "It is time to"
        }
    }

    static let brewQueue = BrewQueue()
}

extension BrewQueue {
    static var empty: BrewQueue {
        return BrewQueue(stages: [])
    }
}

final class BrewQueueViewModel: ObservableObject, Completable {
    let didComplete = PassthroughSubject<BrewQueueViewModel, Never>()

    var stageHeader = StageHeader.welcomeNotReady

    @Published var currentStageViewModel: any BrewStageViewModel = BrewStageConstantViewModel(text: "")

    // TODO: Unify VMs for a single source
    var currentStageTimerViewModel: BrewStageTimerViewModel? {
        currentStageViewModel as? BrewStageTimerViewModel
    }

    var currentStageConstantViewModel: BrewStageConstantViewModel? {
        currentStageViewModel as? BrewStageConstantViewModel
    }

    @Published private(set) var canProceedToNextStep = true

    private var currentStage: BrewStage? {
        didSet {
            hapticGenerator.medium()
            loadStage()
        }
    }

    private(set) var isActive = false

    private var cancellables: [AnyCancellable] = []

    // TODO: Create a real queue data structure for getting the next stage from.
    // The 'play' around the stages[] is tedious & dangerous. That better is encapsulated.
    private var currentStageIndex: UInt = 0 {
        didSet {
            currentStage = brewQueue.stages[safe: Int(currentStageIndex)]
        }
    }

    var brewQueue: BrewQueue {
        selectedRecipe?.brewQueue ?? .empty
    }

    var selectedRecipe: Recipe? {
        recipeRepository.getSelectedRecipe()
    }

    private var title: String {
        selectedRecipe != nil ? "Begin" : "Select a recipe"
    }

    private var subtextIfExists: String? {
        guard let selectedRecipe = selectedRecipe else {
            return nil
        }

        return selectedRecipe.ingredients.toRepresentableString
    }

    private var recipeRepository: RecipeRepository
    private var hapticGenerator: HapticGenerator

    init(
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared, // TODO: use case - no repo in vm!
        hapticGenerator: HapticGenerator = HapticGeneratorImp()
    ) {
        self.recipeRepository = recipeRepository
        self.hapticGenerator = hapticGenerator

        loadInitialStage()
    }

    func primaryAction() {
        if canProceedToNextStep {
            nextStage()
        } else {
            currentStageTimerViewModel?.startOrStop()
        }
    }

    func skipAction() {
        nextStage()
    }

    func endAction() {
        isActive = false
        currentStageIndex = 0
    }

    private func nextStage() {
        guard selectedRecipe != nil else {
            return
        }

        if isActive {
            var tempCurrentStageIndex = currentStageIndex + 1
            if tempCurrentStageIndex >= brewQueue.stages.count {
                isActive = false
                tempCurrentStageIndex = 0
            }
            currentStageIndex = tempCurrentStageIndex
        } else {
            isActive = true
            currentStageIndex = 0
        }
    }

    private func nextStageIfAuto() {
        if canProceedToNextStep && currentStage?.passMethod == .auto {
            self.hapticGenerator.heavy()
            self.nextStage()
        }
    }

    private func loadInitialStage() {
        stageHeader = selectedRecipe != nil ? .welcomeReady : .welcomeNotReady

        currentStageViewModel = BrewStageConstantViewModel(text: title, subtext: subtextIfExists)
        canProceedToNextStep = true
    }

    private func loadStage() {
        guard let currentStage = currentStage else {
            return
        }

        currentStageTimerViewModel?.stop()

        guard isActive else {
            loadInitialStage()
            return
        }

        stageHeader = StageHeader(
            lightTitle: .brewQueue.stageHeader(for: currentStage.action),
            title: currentStage.message,
            subtext: currentStage.details
        )

        switch currentStage.requirement {
        case .none:
            currentStageViewModel = BrewStageConstantViewModel(text: "Done")
        case .countdown(let timeLeft):
            currentStageViewModel = BrewStageTimerViewModel(
                timeIntervalLeft: TimeInterval(timeLeft),
                countdownTimer: CountdownTimerImp(timeLeft: TimeInterval(timeLeft))
            )
        }

        observeTimeIntervalLeft()

        if currentStage.startMethod == .auto {
            currentStageTimerViewModel?.startOrStop()
        }

        canProceedToNextStep = currentStage.requirement == .none
    }

    private func observeTimeIntervalLeft() {
        currentStageTimerViewModel?.$timeIntervalLeft
            .sink(receiveValue: didSinkNewTimeInterval(_:))
            .store(in: &cancellables)
    }

    private func didSinkNewTimeInterval(_ timeInterval: TimeInterval) {
        canProceedToNextStep = timeInterval <= 0
        nextStageIfAuto()
    }

    func showRecipes() {
        didComplete.send(self)
    }
}

struct BrewQueueView: View {
    @ObservedObject var viewModel: BrewQueueViewModel

    var body: some View {

        GeometryReader { proxy in
            ZStack {

                backgroundView
                    .padding(24)

                Group {
                    brewStageView()
                        .shadow(color: .black.opacity(0.2), radius: 16)
                        .onTapGesture {
                            viewModel.primaryAction()
                        }
                        .position(x: (proxy.size.width / 2) - 24, y: (proxy.size.height / 2) - 24)
                }
                .padding(24)

                if let info = viewModel.selectedRecipe?.recipeProfile.brewMethod.info, !info.body.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            InfoButton(infoModel: info)
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.horizontal)
                    .foregroundColor(Color("foregroundPrimary"))
                }
            }
            .backgroundPrimary()
        }
    }

    private var backgroundView: some View {
        HStack {
            Spacer()

            VStack {
                StageHeaderView(header: viewModel.stageHeader)
                Spacer()
                actionButton()
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var recipesButton: some View {
        Button {
            viewModel.showRecipes()
        } label: {
            if let selectedRecipe = viewModel.selectedRecipe {
                RecipeProfileView(alignment: .center, recipeProfile: selectedRecipe.recipeProfile)
            } else {
                Text("Create Recipe")
                    .bold()
                    .font(.title3)
            }
        }
        .padding(12)
        .foregroundColor(Color("foregroundPrimary"))
        .backgroundSecondary()
        .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
    }

    private var skipButton: some View {
        Button {
            viewModel.skipAction()
        } label: {
            Text("Skip")
        }
        .padding()
        .foregroundColor(Color("foregroundPrimary").opacity(0.8))
    }

    private var endButton: some View {
        Button {
            viewModel.endAction()
        } label: {
            Text("End")
        }
        .padding()
        .foregroundColor(Color("foregroundPrimary").opacity(0.8))
    }

    @ViewBuilder
    private func actionButton() -> some View {

        if !viewModel.isActive {
            HStack {
                recipesButton
            }
        } else {
            HStack {
                endButton
                Spacer()
                skipButton
                Spacer()
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func brewStageView() -> some View {
        if let currentStageTimerViewModel = viewModel.currentStageTimerViewModel {
            BrewStageView(viewModel: currentStageTimerViewModel)
        } else if let currentStageConstantViewModel = viewModel.currentStageConstantViewModel {
            BrewStageView(viewModel: currentStageConstantViewModel)
        } else {
            EmptyView()
        }
    }
}

struct BrewQueueView_Previews: PreviewProvider {
    static var previews: some View {
        BrewQueueView(viewModel: .init())
    }
}
