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
        NavigationStack {
            VStack(spacing: 20) {
                let isNewRecord = satisfiedCount > previousHighScore
                
                ZStack {
                    Image("game_over")
                    
                    VStack(alignment: .center, spacing: 10) {
                        
                        Text("Score: \(displayedSatisfied)")
                            .font(.custom("LilitaOne", size: 44))
                            .foregroundColor(Color(hex: "#1794AD"))
                            .offset(y: 5)
                        
                        if isNewRecord {
                            Text("New Highscore: \(displayedSatisfied)")
                                .font(.custom("LilitaOne", size: 28))
                                .foregroundColor(Color(hex: "#1794AD"))
                                .offset(y: 5)
                        } else {
                            Text("Highscore: \(previousHighScore)")
                                .font(.custom("LilitaOne", size: 28))
                                .foregroundColor(Color(hex: "#1794AD"))
                                .offset(y: 20)
                        }
                        
                        Button {
                            onRestart()
                        } label: {
                            Image("play_again_button")
                        }
                        .offset(x: 0, y: 40)
                        
                        NavigationLink(destination: LandingPage()) {
                            Image("home_button")
                        }
                        .offset(y: 50)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
            }
            .onAppear {
                playCounterSoundLooping()
                animateCounter(to: satisfiedCount, state: $displayedSatisfied)
            }
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
            print("❌ Counter Sound file not found")
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
            print("✅ Game Restart")
        }
    )
}

