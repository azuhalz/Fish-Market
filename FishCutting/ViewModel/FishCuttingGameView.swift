import SwiftUI
import _SwiftData_SwiftUI

struct FishCuttingGameView: View {
    @StateObject private var scoreManager = ScoreManager()

    @State private var timeRemaining = 10
    @State private var knifePosition: CGFloat = 0
    @State private var isKnifeMoving = false
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
    @State private var fishOffset: CGFloat = 0
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
    @State private var cutParticles: [UUID: CGPoint] = [:]
    @State private var customerState: CustomerState = .asking
    @State private var showDashedLines = false
    @State private var showTimesUp = false

    
    @Binding var isPlaying: Bool
    
    @Environment(\.modelContext) private var context
    @Query var trackers: [SatisfiedTracker]
    @State private var totalSatisfiedFromDB = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var knifeTimer: Timer?
    
    private let audioManager = AudioManager()
    private let hapticManager = HapticManager()
    
    var body: some View {
        ZStack {
            // Background
//            Color.yellow.opacity(0.3).ignoresSafeArea()
            Image("background_top")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("background_behind")
                .resizable()
                .scaledToFill()
                .offset(y: -15)
            
            
            VStack(spacing: 20) {
                GameHeaderView(
                    timeRemaining: timeRemaining,
                    currentHighScore: currentHighScore,
                    satisfiedCount: satisfiedCount,
                    showPlusOne: showPlusOne,
                    plusOneOffset: plusOneOffset
                )
                
                Spacer().frame(height: 20)
                
                ZStack(alignment: .top) {
                    Color.clear.frame(height: 200)
                    
                    ZStack {
                        CustomerView(
                            customerMessage: customerMessage,
                            currentCustomerIndex: currentCustomerIndex,
                            customerState: customerState,
                            customerOffset: customerOffset,
                            customerOpacity: customerOpacity,
                            hasShownFirstCustomer: hasShownFirstCustomer,
                            fishOffsetX: $fishOffsetX,
                            onFirstCustomerShown: {
                                hasShownFirstCustomer = true
                            }
                        )
                        
                        Image("background_bottom")
                            .resizable()
                            .scaledToFill()
                            .offset(y: 150)
                    }
                }
                .frame(height: 200)
                
                Spacer().frame(height: 60)
                
                ZStack {
                    FishCuttingBoardView(
                        showDashedLines: $showDashedLines,
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
                    .offset(y: -80)
                    
                    KnifeView(
                        isKnifeMoving: isKnifeMoving,
                        isCutting: isCutting,
                        showCutResult: showCutResult,
                        knifePosition: knifePosition
                    )
                }
                .frame(height: 300)
                .overlay(
                    ZStack {
                        ForEach(cutParticles.keys.sorted(), id: \.self) { key in
                            if let pos = cutParticles[key] {
                                CutParticleView(position: pos)
                            }
                        }
                        .offset(x: 33, y: -10)
                    }
                    .allowsHitTesting(false)
                )
                
                Spacer()
            }
            .offset(y: 50)
            
            if showTimesUp {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()

                    Image("Times_Up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .transition(.scale)
                        .zIndex(15)
                }
                .zIndex(15)
            }
          
            if showScore {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    GameOverView(
                        currentScore: score,
                        satisfiedCount: satisfiedCount,
                        previousHighScore: currentHighScore,
                        onRestart: {
                            resetGame()
                        }
                    )
                }
                .transition(.opacity)
                .zIndex(10)
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
        //startKnifeMovement()
        audioManager.playBackgroundMusic()
        showFirstCustomer()
    }
    
    // MARK: - Game Haptics
    func playCutHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - First Customer Animation
    private func showFirstCustomer() {
        customerOffset = 300
        fishOffsetX = 400
        customerOpacity = 0
        showDashedLines = false
        isKnifeMoving = false
        
        // Animate both customer and fish entrance together
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.4)) {
                customerOffset = 0
                fishOffsetX = 0
                customerOpacity = 1
            }
        }
        
        // Start fish animation after entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animateFish()
        }
        
        // Show dashed lines after fish settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.3)) {
                showDashedLines = true
            }
        }
        
        // Start knife movement 1 second after fish is in position
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            startKnifeMovement()
        }
        
        // Mark first customer as shown
        hasShownFirstCustomer = true
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
        isKnifeMoving = true
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

        let id = UUID()
        cutParticles[id] = CGPoint(x: knifePosition + 27, y: 120)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            cutParticles.removeValue(forKey: id)
        }
      
        audioManager.playCutSound()
        playCutHaptic()
        
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
            customerMessage = "\(requestedCuts - fishCuts.count - 1) more cut!"
        }
    }
    
    private func finishCutting() {
        calculateFinalScore()
        roundInProgress = false
        customerState = customerIsSatisfied ? .satisfied : .unsatisfied
        customerMessage = customerIsSatisfied ? "Thank you" : "It's so bad"
        customerIsSatisfied = score >= GameConstants.satisfactionThreshold
        
        if !customerIsSatisfied {
            hapticManager.playUnsatisfiedHaptic()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showCutResult = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    // Synchronize both customer and fish sliding out
                    customerOffset = -300
                    fishOffsetX = -400  // Make fish slide out to the left (same direction as customer)
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
        print("Customer is satisfied? \(customerIsSatisfied)")
        
        if customerIsSatisfied {
            print("✅ Memanggil haptic untuk customer yang puas")
            satisfiedCount += 1
            
            let previousScore = scoreManager.getHighScore()

            scoreManager.updateHighScore(satisfiedCount)
            currentHighScore = previousScore // ← Pass this to GameOverView
            
            triggerPlusOneAnimation()
            
            if let tracker = trackers.first {
                tracker.totalSatisfied += 1
                try? context.save()
            }
        } else {
            print("❌ Customer tidak puas. Memanggil playUnsatisfiedHaptic()")
            hapticManager.playUnsatisfiedHaptic()
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
        customerState = .asking
        requestedCuts = Int.random(in: GameConstants.minCuts...GameConstants.maxCuts)
        customerMessage = "Please cut into \(requestedCuts)"
        currentCustomerIndex = Int.random(in: 1...GameConstants.maxCustomers)
        currentFishIndex = Int.random(in: 1...GameConstants.maxFishTypes)
        knifePosition = 0
        isKnifeMoving = false
        showDashedLines = false
        
        resetFishAnimation()
        
        // Set both customer and fish to their starting positions
        customerOffset = 300
        customerOpacity = 0
        fishOffsetX = 400  // Fish starts from the right
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                // Both slide in together
                customerOffset = 0
                fishOffsetX = 0
                customerOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            animateFish()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.3)) {
                showDashedLines = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            startKnifeMovement()
        }
    }

    // MARK: - Game Control
    private func endGame() {
        if !isKnifeMoving {
            return
        }
        
        isKnifeMoving = false
        knifeTimer?.invalidate()
        audioManager.stopFishSound()
        
        showTimesUp = true
        audioManager.playTimesUpSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showTimesUp = false
            showScore = true
        }
    }


    private func resetGame() {
        isPlaying = false
        customerState = .asking
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
        hasShownFirstCustomer = false
        customerIsSatisfied = false
        isKnifeMoving = false
        
        fishRotation = 0
        fishVerticalOffset = 0
        
        showDashedLines = false
        roundInProgress = true
        
        resetFishAnimation()
        
        // Set starting positions for synchronized entrance
        customerOffset = 300
        customerOpacity = 0
        fishOffsetX = 400
        audioManager.playBackgroundMusic()
        
        // ✅ These two lines are CRUCIAL for the fish to reappear
        fishOffsetX = 400
        isAnimatingFish = false

        // Animate customer and fish entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                // Both slide in together
                customerOffset = 0
                fishOffsetX = 0
                customerOpacity = 1
                fishOffsetX = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            animateFish()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.3)) {
                showDashedLines = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            startKnifeMovement()
        }
    }
}

#Preview {
    FishCuttingGameView(isPlaying: .constant(true))
        .modelContainer(for: SatisfiedTracker.self, inMemory: true)
}
