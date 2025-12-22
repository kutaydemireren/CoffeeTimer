//
//  BrewQueueView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import SwiftUI
import Combine

// TODO: move

protocol URLOpener {
    @MainActor
    @discardableResult
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any]) async -> Bool
}

extension UIApplication: URLOpener { }

//

extension Array where Element == Ingredient {
    func toRepresentableString(joining separator: String) -> String {
        return map { "\($0.toRepresentableString)" }.joined(separator: separator)
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
    let didRequestEdit = PassthroughSubject<Recipe, Never>()

    var stageHeader = StageHeader.welcomeNotReady

    @Published var currentStageViewModel: any BrewStageViewModel = BrewStageConstantViewModel(text: "")
    @Published var isPresentingPostBrew: Bool = false
    @Published var isPresentingGiftView: Bool = false
    @Published var isButtonAnimating = false

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

    // TODO: Create a queue data structure for getting the next stage from.
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
        selectedRecipe != nil ? "Begin" : "No recipe selected"
    }

    private var subtext: String? {
        guard let selectedRecipe = selectedRecipe else {
            return "Create a new one below"
        }

        return selectedRecipe.ingredients.toRepresentableString(joining: "\n")
    }

    private var recipeRepository: RecipeRepository
    private var hapticGenerator: HapticGenerator
    private var urlOpener: URLOpener
    private var analyticsTracker: AnalyticsTracker

    init(
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared, // TODO: use case - no repo in vm!
        hapticGenerator: HapticGenerator = HapticGeneratorImp(),
        urlOpener: URLOpener = UIApplication.shared,
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    ) {
        self.recipeRepository = recipeRepository
        self.hapticGenerator = hapticGenerator
        self.urlOpener = urlOpener
        self.analyticsTracker = analyticsTracker

        loadInitialStage()
    }

    func primaryAction() {
        guard selectedRecipe != nil else {
            withAnimation {
                isButtonAnimating = true
            } completion: { [weak self] in
                self?.isButtonAnimating = false
            }
            return
        }

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
        analyticsTracker.track(event: AnalyticsEvent(name: "brew_cancelled"))
        resetQueue()
    }

    private func resetQueue() {
        UIApplication.shared.isIdleTimerDisabled = false
        isActive = false
        currentStageIndex = 0
    }

    private func beginQueue() {
        UIApplication.shared.isIdleTimerDisabled = true
        isActive = true
        currentStageIndex = 0
        
        let brewMethodType = selectedRecipe?.recipeProfile.brewMethod.path.hasPrefix("custom-method") == true ? "custom" : "built-in"
        let stageCount = brewQueue.stages.count
        analyticsTracker.track(event: AnalyticsEvent(
            name: "brew_started",
            parameters: [
                "brew_method_type": brewMethodType,
                "stage_count": stageCount
            ]
        ))
    }

    private func nextStage() {
        guard selectedRecipe != nil else {
            return
        }

        if isActive {
            let newStageIndex = currentStageIndex + 1
            guard newStageIndex < brewQueue.stages.count else {
                isPresentingPostBrew = true
                resetQueue()
                analyticsTracker.track(event: AnalyticsEvent(name: "brew_completed"))
                return
            }
            
            // Track stage completion
            if let currentStage = currentStage {
                let actionName = stageActionName(for: currentStage.action)
                let method = currentStage.passMethod == .auto ? "auto" : "user"
                analyticsTracker.track(event: AnalyticsEvent(
                    name: "brew_stage_completed",
                    parameters: [
                        "stage_index": Int(currentStageIndex),
                        "action": actionName,
                        "method": method
                    ]
                ))
            }
            
            currentStageIndex = newStageIndex
        } else {
            beginQueue()
        }
    }
    
    private func stageActionName(for action: BrewStageAction) -> String {
        switch action {
        case .boilWater: return "boil_water"
        case .putCoffee: return "put_coffee"
        case .putIce: return "put_ice"
        case .pourWater: return "pour_water"
        case .wet: return "wet"
        case .swirl: return "swirl"
        case .swirlThoroughly: return "swirl_thoroughly"
        case .pause: return "pause"
        case .finish: return "finish"
        case .finishIced: return "finish_iced"
        case .message: return "message"
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

        currentStageViewModel = BrewStageConstantViewModel(text: title, subtext: subtext)
        canProceedToNextStep = true
    }

    func requestEdit() {
        guard let recipe = selectedRecipe else { return }
        analyticsTracker.track(event: AnalyticsEvent(name: "edit_recipe_requested"))
        didRequestEdit.send(recipe)
    }

    func didSaveEditedAmounts() {
        loadInitialStage()
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
        } else {
            currentStageTimerViewModel?.stop()
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

    func confirmGiftCoffee() {
        isPresentingGiftView = false
        analyticsTracker.track(event: AnalyticsEvent(name: "buy_me_a_coffee_opened"))
        redirectToBMC()
    }

    func dismissGiftCoffee() {
        isPresentingGiftView = false
    }

    func confirmPostBrew() {
        isPresentingPostBrew = false
        analyticsTracker.track(event: AnalyticsEvent(name: "buy_me_a_coffee_opened"))
        redirectToBMC()
    }

    private func redirectToBMC() {
        Task { @MainActor in
            guard let url = URL(string: "https://buymeacoffee.com/coffeetimer") else { return }
            await urlOpener.open(url, options: [:])
        }
    }

    func dismissPostBrew() {
        isPresentingPostBrew = false
    }
}

struct BrewQueueView: View {
    @ObservedObject var viewModel: BrewQueueViewModel

    var body: some View {
        if viewModel.isPresentingPostBrew {
            postBrew
        } else {
            queueContent
                .sheet(isPresented: $viewModel.isPresentingGiftView) {
                    GiftCoffeeView(
                        confirm: viewModel.confirmGiftCoffee,
                        dismiss: viewModel.dismissGiftCoffee
                    )
                }
        }
    }

    @ViewBuilder
    private var postBrew: some View {
        PostBrewView(
            confirm: viewModel.confirmPostBrew,
            dismiss: viewModel.dismissPostBrew
        )
    }

    @ViewBuilder
    private var queueContent: some View {
        ZStack {
            brewStageContainer

            VStack {
                StageHeaderView(header: viewModel.stageHeader)
                Spacer()
                actionButtons
                    .padding()
            }
            .padding(24)

            VStack {
                HStack {
                    if !viewModel.isActive {
                        giftButton
                    }
                    Spacer()

                    if let info = viewModel.selectedRecipe?.recipeProfile.brewMethod.info,
                       !info.body.isEmpty {
                        InfoButton(infoModel: info)
                    }
                }
                Spacer()
            }
            .padding(.top, 24)
            .padding(.horizontal, 32)
            .foregroundColor(Color("foregroundPrimary"))
        }
        .backgroundPrimary()
    }

    @ViewBuilder
    private var brewStageContainer: some View {
        GeometryReader { proxy in
            brewStageView
                .opacity(viewModel.selectedRecipe == nil ? 0.5 : 1.0)
                .position(x: (proxy.size.width / 2) - 24, y: (proxy.size.height / 2) - 24)
                .frame(height: 3 * (proxy.size.height / 5))
                .shadow(color: .black.opacity(0.2), radius: 16)
                .onTapGesture {
                    viewModel.primaryAction()
                }
                .padding(24)
        }
    }

    @ViewBuilder
    private var brewStageView: some View {
        if let currentStageTimerViewModel = viewModel.currentStageTimerViewModel {
            BrewStageView(viewModel: currentStageTimerViewModel)
        } else if let currentStageConstantViewModel = viewModel.currentStageConstantViewModel {
            BrewStageView(viewModel: currentStageConstantViewModel)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if !viewModel.isActive {
            HStack {
                recipesButton
                if viewModel.selectedRecipe != nil {
                    editButton
                }
            }
        } else {
            ZStack {
                HStack {
                    endButton
                    Spacer()
                }
                skipButton
            }
        }
    }

    @ViewBuilder
    private var editButton: some View {
        Button {
            viewModel.requestEdit()
        } label: {
            Image(systemName: "pencil")
        }
        .padding(12)
        .foregroundColor(Color("foregroundPrimary"))
        .backgroundSecondary()
        .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
    }

    @ViewBuilder
    private var recipesButton: some View {
        Button {
            viewModel.showRecipes()
        } label: {
            if let selectedRecipe = viewModel.selectedRecipe {
                RecipeProfileView(alignment: .center, recipeProfile: selectedRecipe.recipeProfile)
            } else {
                Text("Create a New Recipe")
                    .bold()
                    .font(.title3)
            }
        }
        .padding(12)
        .foregroundColor(Color("foregroundPrimary"))
        .backgroundSecondary()
        .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
        .scaleEffect(viewModel.isButtonAnimating ? 1.1 : 1)
        .animation(
            Animation.default.repeatCount(1, autoreverses: true),
            value: viewModel.isButtonAnimating
        )
    }

    @ViewBuilder
    private var skipButton: some View {
        Button {
            viewModel.skipAction()
        } label: {
            Text("Skip")
        }
        .padding()
        .foregroundColor(Color("foregroundPrimary").opacity(0.8))
    }

    @ViewBuilder
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
    private var giftButton: some View {
        Button {
            viewModel.isPresentingGiftView = true
        } label: {
            Image(systemName: "gift")
        }
    }
}

struct BrewQueueView_Previews: PreviewProvider {
    static var previews: some View {
        BrewQueueView(viewModel: .init())
            .previewDisplayName("Persistent")

        BrewQueueView(
            viewModel: .init(
                recipeRepository: RecipeRepositoryImp(
                    storage: StorageImp(
                        userDefaults: .init(suiteName: "brew-queue-preview-test")!
                    )
                )
            )
        )
        .previewDisplayName("Not Selected")
    }
}
