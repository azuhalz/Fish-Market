//
//  EndingPage.swift
//  FishCutting
//
//  Created by William Kesuma on 17/07/25.
//

import SwiftUI
import AVFoundation

struct GameOverView: View {
    var Highscore: Int
    var satisfiedCount: Int
    var onPlayAgain: () -> Void

    @State private var displayedScore = 0
    @State private var displayedSatisfied = 0

    let animationDuration = 0.5 // seconds
    let updateInterval = 0.015  // timer interval

    // MARK: - Audio Properties
    @State private var counterSoundPlayer: AVQueuePlayer?
    @State private var counterSoundLooper: AVPlayerLooper?

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Highscore: \(displayedScore)")
                    .font(.title2)
                    .foregroundColor(.white)

                Text("Satisfied Customers: \(displayedSatisfied)")
                    .font(.title3)
                    .foregroundColor(.white)

                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.yellow.opacity(1))
            .cornerRadius(20)
            .padding()
        }
        .onAppear {
            playCounterSoundLooping()
            animateCounter(to: Highscore, state: $displayedScore)
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
                stopCounterSound() // Stop sound when done
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

        // Store in @State so we can stop it later
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

#Preview {
    GameOverView(Highscore: 14, satisfiedCount: 5, onPlayAgain: {})
}

