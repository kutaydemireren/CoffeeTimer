//
//  HapticGenerator.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/07/2023.
//

import UIKit
import AudioToolbox

// TODO: temp

import AVFoundation

enum AudioCue {
    case buttonClick

    var name: String {
        switch self {
        case .buttonClick:
            return "button-click"
        }
    }

    var ext: String {
        switch self {
        case .buttonClick:
            return "wav"
        }
    }
}

final class AudioCuePlayer {
    private var player: AVAudioPlayer?

    func configure(forAudioCue cue: AudioCue) {
        guard let url = Bundle.main.url(forResource: cue.name, withExtension: cue.ext) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error configuring player for (\(cue)): \(error)")
        }
    }

    func play() {
        player?.prepareToPlay()
        player?.play()
    }
}

//

protocol HapticGenerator {
    func heavy()
    func medium()
}

final class HapticGeneratorImp: HapticGenerator {
    let player = {
        let player = AudioCuePlayer()
        player.configure(forAudioCue: .buttonClick)
        return player
    }()

    func heavy() {
        player.play()
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    func medium() {
        player.play()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
