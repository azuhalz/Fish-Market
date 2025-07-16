import SwiftUI
import _SwiftData_SwiftUI

struct FishCuttingGameView: View {
    @State private var timeRemaining = GameConstants.gameDuration
    @State private var knifePosition: CGFloat = 0
    @State private var isKnifeMoving = true
    @State private var fishCuts: [CGFloat] = []
    @State private var score = 0
    @State private var gameStatus = "Tap to cut the fish!"
    @State private var showScore = false
    @State private var currentFishIndex = 1
    @State private var isCutting = false
    @State private var showCutResult = false
    @State private var knifeDirection: CGFloat = 1
    @State private var hasPlayedFishSound = false
    @State private var fishRotation: Double = 0
    @State private var fishVerticalOffset: CGFloat = 0
    @State private var fishOffsetX: CGFloat = 0
    @State private var currentCustomerIndex = 1
    @State private var customerIsSatisfied = false
    @State private var customerMessage = "Please cut into 3"
    @State private var roundInProgress = true
    @State private var transitionToNextCustomer = false
    @State private var satisfiedCount = 0
    @State private var showPlusOne = false
    @State private var plusOneOffset: CGFloat = 0
    @State private var showEmoji = false
    @State private var emojiOffset: CGFloat = 0
    @State private var customerOffset: CGFloat = -200
    @State private var customerOpacity: Double = 0
    @State private var hasShownFirstCustomer = false
    @State private var requestedCuts = 3
    @State private var currentHighScore = 0
    @State private var isAnimatingFish = false
    
    @Binding var isPlaying: Bool
    
    @Environment(\.modelContext) private var context
    @Query var trackers: [SatisfiedTracker]
    @State private var totalSatisfiedFromDB = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var knifeTimer: Timer?
    
    private let audioManager = AudioManager()
    private let hapticManager = HapticManager()
    private let scoreManager = ScoreManager()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 0) {
                GameHeaderView(
                    timeRemaining: timeRemaining,
                    currentHighScore: currentHighScore,
                    satisfiedCount: satisfiedCount,
                    showPlusOne: showPlusOne,
                    plusOneOffset: plusOneOffset
                )
                
                Spacer()
                
                CustomerView(
                    customerMessage: customerMessage,
                    currentCustomerIndex: currentCustomerIndex,
                    customerOffset: customerOffset,
                    customerOpacity: customerOpacity,
                    hasShownFirstCustomer: hasShownFirstCustomer,
                    fishOffsetX: $fishOffsetX,
                    onFirstCustomerShown: {
                        hasShownFirstCustomer = true
                    }
                )
                
                Spacer()
                
                FishCuttingBoardView(
                    showCutResult: showCutResult,
                    currentFishIndex: currentFishIndex,
                    fishRotation: fishRotation,
                    fishOffsetX: fishOffsetX,
                    fishVerticalOffset: fishVerticalOffset,
                    requestedCuts: requestedCuts,
                    fishCuts: fishCuts,
                    hasPlayedFishSound: hasPlayedFishSound,
                    onFishAppear: {
                        if !hasPlayedFishSound {
                            hasPlayedFishSound = true
                            animateFish()
                        }
                    },
                    onFishIndexChange: {
                        resetFishAnimation()
                    }
                )
                
                KnifeView(
                    isKnifeMoving: isKnifeMoving,
                    isCutting: isCutting,
                    showCutResult: showCutResult,
                    knifePosition: knifePosition
                )
                
                Spacer()
                
                if showScore {
                    Button("Play Again") {
                        resetGame()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .onTapGesture {
            cutFish()
        }
        .onAppear {
            setupGame()
        }
        .onReceive(timer) { _ in
            handleTimer()
        }
    }
    
    // MARK: - Game Setup
    private func setupGame() {
        currentHighScore = scoreManager.getHighScore()
        
        if let tracker = trackers.first {
            totalSatisfiedFromDB = tracker.totalSatisfied
        } else {
            let newTracker = SatisfiedTracker(totalSatisfied: 0)
            context.insert(newTracker)
            try? context.save()
            totalSatisfiedFromDB = 0
        }
        
        hapticManager.prepareHaptics()
        startKnifeMovement()
        audioManager.playBackgroundMusic()
    }
    
    // MARK: - Timer Handling
    private func handleTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else if !showScore {
            endGame()
        }
    }
    
    // MARK: - Knife Movement
    private func startKnifeMovement() {
        knifeTimer?.invalidate()
        knifeTimer = Timer.scheduledTimer(withTimeInterval: GameConstants.knifeUpdateInterval, repeats: true) { _ in
            guard isKnifeMoving else { return }
            
            let speed: CGFloat = timeRemaining <= GameConstants.speedUpThreshold ?
                GameConstants.fastKnifeSpeed : GameConstants.normalKnifeSpeed
            
            knifePosition += speed * knifeDirection
            let maxKnife = GameConstants.fishWidth
            let minKnife: CGFloat = 0
            
            if knifePosition >= maxKnife {
                knifePosition = maxKnife
                knifeDirection = -1
            } else if knifePosition <= minKnife {
                knifePosition = minKnife
                knifeDirection = 1
            }
        }
    }
    
    // MARK: - Fish Animation
    private func animateFish() {
        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            fishRotation = 10
            fishVerticalOffset = 10
        }
    }
    
    private func resetFishAnimation() {
        fishRotation = 0
        fishVerticalOffset = 0
        fishOffsetX = 400
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.5)) {
                fishOffsetX = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animateFish()
        }
    }
    
    // MARK: - Cutting Logic
    private func cutFish() {
        guard fishCuts.count < requestedCuts - 1,
              timeRemaining > 0,
              !isCutting,
              roundInProgress,
              !showCutResult else { return }
        
        audioManager.playCutSound()
        hapticManager.playHapticCut()
        
        isCutting = true
        isKnifeMoving = false
        fishCuts.append(knifePosition)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isCutting = false
            isKnifeMoving = true
        }
        
        if fishCuts.count == requestedCuts - 1 {
            finishCutting()
        } else {
            customerMessage = "One more cut!"
        }
    }
    
    private func finishCutting() {
        calculateFinalScore()
        roundInProgress = false
        customerMessage = customerIsSatisfied ? "Thank you" : "It's so bad"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCutResult = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    customerOffset = 300
                    fishOffsetX = 400
                    customerOpacity = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if timeRemaining > 0 {
                startNextRound()
            } else {
                showScore = true
            }
        }
    }
    
    // MARK: - Score Calculation
    private func calculateFinalScore() {
        let sortedCuts = fishCuts.sorted()
        var totalScore: CGFloat = 0
        
        for i in 1..<requestedCuts {
            let ideal = GameConstants.fishWidth * CGFloat(i) / CGFloat(requestedCuts)
            let actual = sortedCuts[i - 1]
            let distance = abs(actual - ideal)
            let score = max(0, 100 - distance * 1.2)
            totalScore += score
        }
        
        score = Int(totalScore / CGFloat(requestedCuts - 1))
        customerIsSatisfied = score >= GameConstants.satisfactionThreshold
        
        if customerIsSatisfied {
            satisfiedCount += 1
            scoreManager.updateHighScore(satisfiedCount)
            currentHighScore = scoreManager.getHighScore()
            triggerPlusOneAnimation()
            
            if let tracker = trackers.first {
                tracker.totalSatisfied += 1
                try? context.save()
            }
        }
    }
    
    // MARK: - Animation Effects
    private func triggerPlusOneAnimation() {
        showPlusOne = true
        plusOneOffset = 0
        showEmoji = true
        emojiOffset = 0
        
        audioManager.playPlusOneSound()
        
        withAnimation(.easeOut(duration: 0.6)) {
            plusOneOffset = -40
            emojiOffset = -60
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showPlusOne = false
            showEmoji = false
        }
    }
    
    // MARK: - Round Management
    private func startNextRound() {
        fishCuts = []
        isCutting = false
        showCutResult = false
        roundInProgress = true
        requestedCuts = Int.random(in: GameConstants.minCuts...GameConstants.maxCuts)
        customerMessage = "Please cut into \(requestedCuts)"
        currentCustomerIndex = Int.random(in: 1...GameConstants.maxCustomers)
        currentFishIndex = Int.random(in: 1...GameConstants.maxFishTypes)
        knifePosition = 0
        isKnifeMoving = true
        
        resetFishAnimation()
        customerOffset = -300
        customerOpacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                customerOffset = 0
                fishOffsetX = 0
                customerOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            animateFish()
        }
    }
    
    // MARK: - Game Control
    private func endGame() {
        showScore = true
        isKnifeMoving = false
        knifeTimer?.invalidate()
        audioManager.stopFishSound()
    }
    
    private func resetGame() {
        isPlaying = false
        requestedCuts = Int.random(in: GameConstants.minCuts...GameConstants.maxCuts)
        customerMessage = "Please cut into \(requestedCuts)"
        timeRemaining = GameConstants.gameDuration
        fishCuts = []
        score = 0
        satisfiedCount = 0
        gameStatus = "Tap to cut the fish!"
        showScore = false
        showCutResult = false
        isCutting = false
        knifePosition = 0
        currentFishIndex = Int.random(in: 1...GameConstants.maxFishTypes)
        currentCustomerIndex = Int.random(in: 1...GameConstants.maxCustomers)
        isKnifeMoving = true
        fishRotation = 0
        fishVerticalOffset = 0
        animateFish()
        startKnifeMovement()
        customerOffset = -300
        customerOpacity = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                customerOffset = 0
                customerOpacity = 1
            }
        }
    }
}

#Preview {
    FishCuttingGameView(isPlaying: .constant(true))
        .modelContainer(for: SatisfiedTracker.self, inMemory: true)
}
