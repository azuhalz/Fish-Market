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
    @State private var timeRemaining = 60
    @State private var knifePosition: CGFloat = 0
    @State private var isKnifeMoving = true
    @State private var fishCuts: [CGFloat] = []
    @State private var score = 0
    @State private var showScore = false
    @State private var currentFishIndex = 1
    @State private var isCutting = false
    @State private var showCutResult = false
    @State private var knifeDirection: CGFloat = 1
    @State private var cutAudioPlayer: AVAudioPlayer?
    @State private var fishAudioPlayer: AVAudioPlayer?
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
    
    @Environment(\.modelContext) private var context
    @Query var trackers: [SatisfiedTracker]
    @State private var totalSatisfiedFromDB = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var knifeTimer: Timer?
    
    let fishWidth: CGFloat = 300
    let fishHeight: CGFloat = 150
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.orange)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    ZStack {
                        Text("Satisfied: \(satisfiedCount)")
                            .font(.title3)
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
                
                Text(customerMessage)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                
                Image("person_\(currentCustomerIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: customerOffset)
                    .opacity(customerOpacity)
                    .animation(.easeOut(duration: 0.5), value: customerOffset)
                    .onAppear {
                        if !hasShownFirstCustomer {
                            hasShownFirstCustomer = true
                            customerOffset = 300
                            customerOpacity = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    customerOffset = 0
                                    customerOpacity = 1
                                }
                            }
                        }
                    }
                
                ZStack {
                    if !showCutResult {
                        Image("cut_board")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 200)
                        
                        Image("fish\(currentFishIndex)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: fishWidth, height: fishHeight)
                            .rotationEffect(.degrees(fishRotation))
                            .offset(x: fishOffsetX, y: fishVerticalOffset)
                            .onAppear {
                                if !hasPlayedFishSound {
                                    hasPlayedFishSound = true
                                    playFishSound()
                                    animateFish()
                                }
                            }
                        
                        ForEach(1..<requestedCuts, id: \.self) { i in
                            let x = fishWidth * CGFloat(i) / CGFloat(requestedCuts)
                            DashedLine()
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .frame(width: 2, height: fishHeight)
                                .offset(x: x - fishWidth/2)
                        }
                        
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
                
                ZStack {
                    if isKnifeMoving || isCutting || showCutResult {
                        Image("knife")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .offset(x: knifePosition - fishWidth/2, y: -30)
                            .animation(.none, value: knifePosition)
                    }
                }
                
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
        .onTapGesture { cutFish() }
        .onChange(of: isPlaying, { oldValue, newValue in
            if newValue {
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
            }
        })
        .onReceive(timer) { _ in
            if isPlaying {
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
    }
    
    func resetGame() {
        timeRemaining = 60
        satisfiedCount = 0
        fishCuts = []
        showScore = false
        isKnifeMoving = true
        knifePosition = 0 // ✅ Reset knife to far left
        knifeDirection = 1 // ✅ Start moving right again
        currentFishIndex = 1
        currentCustomerIndex = 1
        requestedCuts = 3
        customerMessage = "Please cut into 3"
        roundInProgress = true
        showCutResult = false
        startKnifeMovement()
        animateFish()
    }
    

    func startKnifeMovement() {
        knifeTimer?.invalidate()
        knifeTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            guard isKnifeMoving else { return }

            // Speed up when timeRemaining is 10 or less
            let speed: CGFloat = timeRemaining <= 10 ? 4.5 : 3

            knifePosition += speed * knifeDirection
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        customerOffset = 300
                        customerOpacity = 0
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
        fishOffsetX = 0
        fishRotation = 0
        fishVerticalOffset = 0
        animateFish()
        customerOffset = -300
        customerOpacity = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                customerOffset = 0
                customerOpacity = 1
            }
        }
    }

    func splitFishView() -> some View {
        HStack(spacing: 5) {
            ForEach(1...requestedCuts, id: \.self) { i in
                Image("fish_cut_\(i)")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 200)
    }

    func playCutSound() {
        if let soundURL = Bundle.main.url(forResource: "cut_sound", withExtension: "wav") {
            cutAudioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
            cutAudioPlayer?.play()
        }
    }

    func playFishSound() {
        if let fishSoundURL = Bundle.main.url(forResource: "fish_flop", withExtension: "wav") {
            fishAudioPlayer = try? AVAudioPlayer(contentsOf: fishSoundURL)
            fishAudioPlayer?.numberOfLoops = -1
            fishAudioPlayer?.play()
        }
    }

    func stopFishSound() {
        fishAudioPlayer?.stop()
    }

    func animateFish() {
        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            fishVerticalOffset = -10
        }
    }

    func playHapticCut() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let duration: TimeInterval = 0.3
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptics not available: \(error.localizedDescription)")
        }
    }

    func calculateFinalScore() {
        let sortedCuts = fishCuts.sorted()
        var widths: [CGFloat] = []
        var lastX: CGFloat = 0
        for i in 0..<requestedCuts {
            let nextX = i < sortedCuts.count ? sortedCuts[i] : fishWidth
            widths.append(nextX - lastX)
            lastX = nextX
        }
        let average = widths.reduce(0, +) / CGFloat(widths.count)
        let maxDiff = widths.map { abs($0 - average) }.max() ?? 0
        customerIsSatisfied = maxDiff < 15
        
        if customerIsSatisfied {
            satisfiedCount += 1
            if let tracker = trackers.first {
                tracker.totalSatisfied += 1
                try? context.save()
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
    ContentView(isPlaying: .constant(false))
}
