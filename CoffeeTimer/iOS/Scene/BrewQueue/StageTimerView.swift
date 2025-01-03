//
//  SingleStageTimerView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 13/03/2023.
//

import SwiftUI
import Combine

extension TimeInterval {
    var toRepresentableString: String {
        String(format: "%d", Int(self))
    }
}

protocol BrewStageViewModel: ObservableObject {
    var text: String { get }
    var subtext: String? { get }
    var progress: Double { get }
    var isPaused: Bool { get }
}

final class BrewStageConstantViewModel: BrewStageViewModel {
    @Published var text: String
    @Published var subtext: String?
    let isPaused = false
    let progress = 1.0

    init(text: String, subtext: String? = nil) {
        self.text = text
        self.subtext = subtext
    }
}

final class BrewStageTimerViewModel: BrewStageViewModel {
    @Published var text: String = ""
    @Published var subtext: String? = nil
    @Published var isPaused = false
    @Published var progress: Double = 0.0
    @Published private(set) var timeIntervalLeft: TimeInterval {
        didSet {
            withAnimation(.linear(duration: 0.3)) { progress = (duration - timeIntervalLeft) / duration }
            text = timeIntervalLeft.toRepresentableString
        }
    }
    private let duration: TimeInterval

    private var cancellables: [AnyCancellable] = []

    private var countdownTimer: CountdownTimer

    init(
        timeIntervalLeft: TimeInterval,
        countdownTimer: CountdownTimer
    ) {
        self.duration = timeIntervalLeft
        self.timeIntervalLeft = timeIntervalLeft
        self.countdownTimer = countdownTimer

        countdownTimer.timeLeftPublisher
            .sink { timeIntervalLeft in
                self.timeIntervalLeft = timeIntervalLeft
            }
            .store(in: &cancellables)
    }

    func startOrStop() {
        if countdownTimer.isRunning {
            stop()
        } else {
            try? countdownTimer.start()
            isPaused = false
        }
    }

    func stop() {
        countdownTimer.stop()
        isPaused = true
    }
}

struct BrewStageView<ViewModel>: View where ViewModel: BrewStageViewModel {
    @ObservedObject var viewModel: ViewModel
    @State private var isAnimating = false

    var body: some View {

        ZStack {
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(Color("backgroundSecondary"), style: .init(lineWidth: 4))
                .contentShape(Circle())

            Circle()
                .trim(from: viewModel.progress, to: 1.0)
                .stroke(Color("backgroundSecondary").opacity(0.3), style: .init(lineWidth: 4))
                .contentShape(Circle())
        }
        .rotationEffect(.degrees(-90))
        .overlay {
            ZStack {
                VStack {
                    Text(viewModel.text)
                        .font(.largeTitle)
                    if let subtext = viewModel.subtext {
                        Text(subtext)
                            .font(.body)
                    }
                }
                VStack {
                    Spacer()
                    if viewModel.isPaused {
                        Image(systemName: "play.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .scaleEffect(isAnimating ? 1.1 : 1)
                            .opacity(isAnimating ? 0.4 : 0.8)
                            .padding()
                            .animation(
                                Animation
                                    .easeInOut(duration: 1.5)
                                    .delay(0.5)
                                    .repeatForever(),
                                value: isAnimating
                            )
                            .onAppear {
                                isAnimating = true
                            }
                            .onDisappear {
                                isAnimating = false
                            }
                    }
                }
            }
            .foregroundColor(.init("backgroundSecondary"))
            .padding()
            .multilineTextAlignment(.center)
        }
    }
    
}

struct BrewStageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            BrewStageView(viewModel: BrewStageTimerViewModel(timeIntervalLeft: 10, countdownTimer: CountdownTimerImp(timeLeft: 5)))
            Spacer()
        }
        .padding()
        .backgroundPrimary()
    }
}
