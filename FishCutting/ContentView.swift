import SwiftUI
import _SwiftData_SwiftUI
import AVFoundation
import CoreHaptics

struct ContentView: View {
    @Binding var isPlaying: Bool
    
    var body: some View {
        FishCuttingGameView(isPlaying: $isPlaying)
    }
}

struct FishCuttingGameView: View {
    @State private var timeRemaining = 5
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
    @State private var cutAudioPlayer: AVAudioPlayer?
    @State private var fishAudioPlayer: AVAudioPlayer?
    @State private var bgAudioPlayer: AVAudioPlayer?
    @State private var hasPlayedFishSound = false
    @State private var fishRotation: Double = 0
    @State private var fishVerticalOffset: CGFloat = 0
    @State private var fishOffsetX: CGFloat = 0
    @State private var hapticEngine: CHHapticEngine?
    @State private var currentCustomerIndex = 1
    @State private var customerIsSatisfied = false
    @State private var customerMessage = "Please cut into 3"
    @State private var roundInProgress = true
    @State private var transitionToNextCustomer = false
    @State private var satisfiedCount = 0
    @State private var showPlusOne = false
    @State private var plusOneOffset: CGFloat = 0
    @State private var plusOnePlayer: AVAudioPlayer?
    @State private var showEmoji = false
    @State private var emojiOffset: CGFloat = 0
    @State private var customerOffset: CGFloat = -200
    @State private var customerOpacity: Double = 0
    @State private var hasShownFirstCustomer = false
    @State private var requestedCuts = 3
    @Binding var isPlaying: Bool
    @State private var currentHighScore = 0
    @State private var isAnimatingFish = false
    
    @Environment(\.modelContext) private var context
    @Query var trackers: [SatisfiedTracker]
    @State private var totalSatisfiedFromDB = 0
    
    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Animation timer for knife movement
    @State private var knifeTimer: Timer?
    
    let fishWidth: CGFloat = 230
    let fishHeight: CGFloat = 115
    // Membagi ikan menjadi 3 bagian sama rata (1/3 dan 2/3)
    let targetCuts: [CGFloat] = [100, 200] // fishWidth/3 dan 2*fishWidth/3
    
    var body: some View {
        ZStack {
            // Background
            Color.yellow.opacity(0.3)
                .ignoresSafeArea()
            
            VStack (spacing: 0) {
                // Header
                HStack {
                    Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.orange)
                        .cornerRadius(10)

                    Spacer()

                    Text("Highscore:\(currentHighScore)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(10)

                    Spacer()

                    ZStack {
                        Text("Satisfied: \(satisfiedCount)")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.green)
                            .cornerRadius(10)

                        if showPlusOne {
                            Text("+1")
                                .font(.title3)
                                .foregroundColor(.yellow)
                                .offset(y: plusOneOffset)
                                .transition(.opacity)
                        }
                    }
                }
                .padding(20)
                
                Spacer()
                
                // Instructions
                Text(customerMessage)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                
                // Person customer
                Image("person_\(currentCustomerIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .offset(x: customerOffset)
                    .opacity(customerOpacity)
                    .animation(.easeOut(duration: 0.5), value: customerOffset)
                
                    .onAppear {
                        if !hasShownFirstCustomer {
                            hasShownFirstCustomer = true
                            customerOffset = 300
                            fishOffsetX = 400
                            customerOpacity = 0
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    customerOffset = 0
                                    fishOffsetX = 0
                                    customerOpacity = 1
                                }
                            }
                        }
                    }
                
                Spacer()
                
                ZStack {
                    if !showCutResult {
                        Image("cut_board")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 330, height: 165)
                        
                        Image("fish\(currentFishIndex)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: fishWidth, height: fishHeight)
                            .rotationEffect(.degrees(fishRotation))
                            .offset(x: fishOffsetX, y: fishVerticalOffset)
                            .onAppear {
                                if !hasPlayedFishSound {
                                    hasPlayedFishSound = true
                                    animateFish()  // Start animation on the first appearance
                                }
                            }
                            .onChange(of: currentFishIndex) { _ in
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
                            
                            // Dash lines for the cuts
                            ForEach(1..<requestedCuts, id: \.self) { i in
                                let x = fishWidth * CGFloat(i) / CGFloat(requestedCuts)
                                DashedLine()
                                    .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    .frame(width: 2, height: fishHeight)
                                    .offset(x: x - fishWidth/2)
                            }

                            // Cut marks
                            ForEach(Array(fishCuts.enumerated()), id: \.offset) { index, cutPosition in
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 3, height: fishHeight)
                                    .offset(x: cutPosition - fishWidth/2)
                            }
                        } else {
                            splitFishView()
                        }
                }
                
                // Moving knife + guide line
                ZStack {
                    if isKnifeMoving || isCutting || showCutResult {
                        Image("knife")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 300)
                            .offset(x: knifePosition - fishWidth/2, y: -130)
                            .animation(.none, value: knifePosition)
                    }
                }
                
                // Cut indicators
//                HStack(){
//                    ForEach(0..<requestedCuts - 1, id: \.self) { index in
//                        Image("knife")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 60, height: 60)
//                            .rotationEffect(Angle(degrees: -45))
//                            .foregroundColor(index < fishCuts.count ? .green : .gray)
//                            .opacity(index < fishCuts.count ? 1.0 : 0.3)
//                    }
//                }
//                
//                Text(gameStatus)
//                    .font(.headline)
//                    .foregroundColor(.black)
//                    .padding(.vertical, 10)
                
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
            currentHighScore = UserDefaults.standard.integer(forKey: "highscore")

            if let tracker = trackers.first {
                totalSatisfiedFromDB = tracker.totalSatisfied
            } else {
                let newTracker = SatisfiedTracker(totalSatisfied: 0)
                context.insert(newTracker)
                try? context.save()
                totalSatisfiedFromDB = 0
            }

            prepareHaptics()
            startKnifeMovement()
            playBackgroundMusic()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else if !showScore {
                showScore = true
                isKnifeMoving = false
                knifeTimer?.invalidate()
                stopFishSound()
            }
        }
    }
    
    func calculateSegmentWidths() -> [CGFloat] {
        let sortedCuts = fishCuts.sorted()
        let totalWidth = fishWidth
        let pieces = requestedCuts
        var widths: [CGFloat] = []
        
        var lastX: CGFloat = 0
        for i in 0..<pieces {
            let nextX = i < sortedCuts.count ? sortedCuts[i] : totalWidth
            widths.append(nextX - lastX)
            lastX = nextX
        }
        return widths
    }
    
    @ViewBuilder
    func splitFishView() -> some View {
        HStack(spacing: 5) {
            ForEach(1...requestedCuts, id: \.self) { i in
                Image("fish_cut_\(i)")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 165)
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Gagal memulai haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playHapticCut() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let duration: TimeInterval = 0.3
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Gagal memainkan haptic: \(error.localizedDescription)")
        }
    }
    
    
    func startKnifeMovement() {
        knifeTimer?.invalidate()
        
        knifeTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if isKnifeMoving {
                knifePosition += 2 * knifeDirection
                
                let maxKnife = fishWidth
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
    }
    
    
    func cutFish() {
        guard fishCuts.count < requestedCuts - 1,
              timeRemaining > 0,
              !isCutting,
              roundInProgress,
              !showCutResult else { return }
        
        playCutSound()
        playHapticCut()
        
        isCutting = true
        isKnifeMoving = false
        fishCuts.append(knifePosition)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isCutting = false
            isKnifeMoving = true
        }
        
        if fishCuts.count == requestedCuts - 1 {
            calculateFinalScore()
            roundInProgress = false
            customerMessage = customerIsSatisfied ? "Thank you" : "It's so bad"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCutResult = true
                
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
            
        } else {
            customerMessage = "One more cut!"
        }
    }
    
    func startNextRound() {
        fishCuts = []
        isCutting = false
        showCutResult = false
        roundInProgress = true
        requestedCuts = Int.random(in: 2...4)
        customerMessage = "Please cut into \(requestedCuts)"
        currentCustomerIndex = Int.random(in: 1...3)
        currentFishIndex = Int.random(in: 1...5)
        knifePosition = 0
        isKnifeMoving = true
        
        fishRotation = 0
        fishVerticalOffset = 0
        
        fishOffsetX = 400
        customerOffset = 300
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
    
    func playBackgroundMusic() {
        if let soundURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            do {
                bgAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                bgAudioPlayer?.play()
            } catch {
                print("Gagal memutar suara: \(error.localizedDescription)")
            }
        }
    }
    
    func playCutSound() {
        if let soundURL = Bundle.main.url(forResource: "cut_sound", withExtension: "wav") {
            do {
                cutAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                cutAudioPlayer?.play()
            } catch {
                print("Gagal memutar suara: \(error.localizedDescription)")
            }
        }
    }
    
    func stopFishSound() {
        fishAudioPlayer?.stop()
    }
    
    func animateFish() {
        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            fishRotation = 10
            fishVerticalOffset = 10
        }
    }
    
    func playPlusOneSound() {
        if let url = Bundle.main.url(forResource: "point_up", withExtension: "wav") {
            do {
                plusOnePlayer = try AVAudioPlayer(contentsOf: url)
                plusOnePlayer?.play()
            } catch {
                print("Gagal play plus one sound: \(error.localizedDescription)")
            }
        }
    }
    
    func triggerPlusOneAnimation() {
        showPlusOne = true
        plusOneOffset = 0
        showEmoji = true
        emojiOffset = 0
        
        playPlusOneSound()
        
        withAnimation(.easeOut(duration: 0.6)) {
            plusOneOffset = -40
            emojiOffset = -60
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showPlusOne = false
            showEmoji = false
        }
    }
    
    func calculateFinalScore() {
        guard fishCuts.count == requestedCuts - 1 else { return }
        
        let sortedCuts = fishCuts.sorted()
        var totalScore: CGFloat = 0

        for i in 1..<requestedCuts {
            let ideal = fishWidth * CGFloat(i) / CGFloat(requestedCuts)
            let actual = sortedCuts[i - 1]
            let distance = abs(actual - ideal)
            let score = max(0, 100 - distance * 1.2)
            totalScore += score
        }

        score = Int(totalScore / CGFloat(requestedCuts - 1))

        customerIsSatisfied = score >= 80
        customerMessage = customerIsSatisfied ? "Thank you" : "It's so bad"

        if customerIsSatisfied {
            satisfiedCount += 1  // Track how many customers are satisfied

            updateHighScore()

            triggerPlusOneAnimation()

            if let tracker = trackers.first {
                tracker.totalSatisfied += 1
                try? context.save()
            }
        }
        print("Requested cuts: \(requestedCuts)")
        print("Final Score: \(score)")
    }

    func updateHighScore() {
        if satisfiedCount > currentHighScore {
            currentHighScore = satisfiedCount
            UserDefaults.standard.set(currentHighScore, forKey: "highscore") // Save the new high score in UserDefaults
        }
    }
    
    func endGame() {
        knifeTimer?.invalidate()
        isKnifeMoving = false
        stopFishSound()
        if fishCuts.count < 2 {
            gameStatus = "Time's up! Try again!"
        }
        showScore = true
    }
    
    func resetGame() {
        isPlaying = false
        requestedCuts = Int.random(in: 2...4)
        customerMessage = "Please cut into \(requestedCuts)"
        timeRemaining = 5
        fishCuts = []
        score = 0
        satisfiedCount = 0
        gameStatus = "Tap to cut the fish!"
        showScore = false
        showCutResult = false
        isCutting = false
        knifePosition = 0
        currentFishIndex = Int.random(in: 1...5)
        currentCustomerIndex = Int.random(in: 1...3)
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

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

#Preview {
    ContentView(isPlaying: .constant(true))
}
