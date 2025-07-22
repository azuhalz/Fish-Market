//
//  EndingPage.swift
//  FishCutting
//
//  Created by William Kesuma on 17/07/25.
//

import SwiftUI
import AVFoundation

struct GameOverView: View {
    let currentScore: Int
    let satisfiedCount: Int
    let previousHighScore: Int
    let onRestart: () -> Void

    @State private var displayedScore = 0
    @State private var displayedSatisfied = 0

    let animationDuration = 0.5 // seconds
    let updateInterval = 0.015  // timer interval

    // MARK: - Audio Properties
    @State private var counterSoundPlayer: AVQueuePlayer?
    @State private var counterSoundLooper: AVPlayerLooper?

    var body: some View {
        VStack(spacing: 20) {
            let isNewRecord = satisfiedCount > previousHighScore

            Text("GAME OVER")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if isNewRecord {
                Text("NEW HIGHSCORE: \(displayedSatisfied)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            } else {
                Text("HIGHSCORE: \(previousHighScore)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text("YOUR SCORE: \(displayedSatisfied)")
                .font(.title3)
                .foregroundColor(.white)

            Button("Play Again") {
                onRestart()
            }
            .font(.title2)
            .padding()
            .background(Color.white)
            .foregroundColor(.orange)
            .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.8))
        )
        .onAppear {
            playCounterSoundLooping()
            animateCounter(to: satisfiedCount, state: $displayedSatisfied)
        }
    }

    // MARK: - Animate Counter
    func animateCounter(to target: Int, state: Binding<Int>) {
        let steps = Int(animationDuration / updateInterval)
        let increment = Double(target) / Double(steps)
        var currentStep = 0

        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            if currentStep >= steps {
                state.wrappedValue = target
                stopCounterSound()
                timer.invalidate()
            } else {
                state.wrappedValue = min(target, Int(Double(currentStep) * increment))
                currentStep += 1
            }
        }
    }

    // MARK: - Audio Functions
    func playCounterSoundLooping() {
        guard let url = Bundle.main.url(forResource: "Counter_Sound", withExtension: "mp4") else {
            print("⚠️ Counter_Sound.mp4 not found in bundle.")
            return
        }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        let player = AVQueuePlayer()
        let looper = AVPlayerLooper(player: player, templateItem: item)

        player.volume = 1.0
        player.play()

        counterSoundPlayer = player
        counterSoundLooper = looper
    }

    func stopCounterSound() {
        counterSoundPlayer?.pause()
        counterSoundPlayer?.removeAllItems()
        counterSoundPlayer = nil
        counterSoundLooper = nil
    }
}

// MARK: - Preview
#Preview {
    GameOverView(
        currentScore: 12,
        satisfiedCount: 15,
        previousHighScore: 10,
        onRestart: {
            print("Restart tapped")
        }
    )
}

