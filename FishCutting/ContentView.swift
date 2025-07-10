import SwiftUI

struct ContentView: View {
    var body: some View {
        FishCuttingGameView()
    }
}

struct FishCuttingGameView: View {
    @State private var timeRemaining = 40
    @State private var knifePosition: CGFloat = 0
    @State private var isKnifeMoving = true
    @State private var fishCuts: [CGFloat] = []
    @State private var score = 0
    @State private var gameStatus = "Tap to cut the fish!"
    @State private var showScore = false
    @State private var currentFishIndex = 1
    @State private var isCutting = false
    @State private var showCutResult = false
    
    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Animation timer for knife movement
    @State private var knifeTimer: Timer?
    
    let fishWidth: CGFloat = 300
    let fishHeight: CGFloat = 150
    // Membagi ikan menjadi 3 bagian sama rata (1/3 dan 2/3)
    let targetCuts: [CGFloat] = [100, 200] // fishWidth/3 dan 2*fishWidth/3
    
    var body: some View {
        ZStack {
            // Background
            Color.yellow.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                // Header with timer and back button
                HStack {
                    Button(action: {
                        // Back button action
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(10)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Fish market background (decorative)
                Text("🐟 Fish Market 🐟")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .opacity(0.7)
                
                Spacer()
                
                // Instructions
                Text("Please cut into 3")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                
                Spacer()
                
                // Game Area
                ZStack {
                    // Fish cutting area
                    VStack {
                        // Knife area
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: fishWidth, height: 60)
                            
                            // Moving knife
                            if isKnifeMoving && !isCutting {
                                Image("knife")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(x: knifePosition - fishWidth/2)
                                    .animation(.none, value: knifePosition)
                            }
                            
                            // Cutting knife animation
                            if isCutting {
                                Image("knife")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(x: knifePosition - fishWidth/2, y: 20)
                                    .animation(.easeInOut(duration: 0.3), value: isCutting)
                            }
                        }
                        
                        // Fish with cutting guides
                        ZStack {
                            if !showCutResult {
                                // Original fish
                                Image("fish\(currentFishIndex)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: fishWidth, height: fishHeight)
                                
                                // Cutting guide lines - membagi menjadi 3 bagian sama rata
                                ForEach([fishWidth/3, 2*fishWidth/3], id: \.self) { cutPosition in
                                    DashedLine()
                                        .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        .frame(width: 2, height: fishHeight)
                                        .offset(x: cutPosition - fishWidth/2)
                                }
                                
                                // Cut marks
                                ForEach(Array(fishCuts.enumerated()), id: \.offset) { index, cutPosition in
                                    Rectangle()
                                        .fill(Color.red)
                                        .frame(width: 3, height: fishHeight)
                                        .offset(x: cutPosition - fishWidth/2)
                                }
                            } else {
                                // Cut fish result
                                HStack(spacing: 5) {
                                    // First piece
                                    Image("fish_cut_1")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: fishWidth/3 - 5, height: fishHeight)
                                    
                                    // Second piece
                                    Image("fish_cut_2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: fishWidth/3 - 5, height: fishHeight)
                                    
                                    // Third piece
                                    Image("fish_cut_3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: fishWidth/3 - 5, height: fishHeight)
                                }
                                .animation(.easeInOut(duration: 0.5), value: showCutResult)
                            }
                        }
                        
                        // Cut indicators
                        HStack {
                            ForEach(0..<3) { index in
                                Image(systemName: "scissors")
                                    .font(.title2)
                                    .foregroundColor(index < fishCuts.count ? .green : .gray)
                                    .opacity(index < fishCuts.count ? 1.0 : 0.3)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .frame(height: 300)
                .onTapGesture {
                    cutFish()
                }
                
                Spacer()
                
                // Status and Score
                VStack {
                    Text(gameStatus)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    if showScore {
                        VStack {
                            Text("Final Score: \(score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Button("Play Again") {
                                resetGame()
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            startKnifeMovement()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 && !showScore {
                timeRemaining -= 1
            } else if timeRemaining == 0 && !showScore {
                endGame()
            }
        }
    }
    
    func startKnifeMovement() {
        knifeTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if isKnifeMoving {
                knifePosition += 2
                if knifePosition > fishWidth {
                    knifePosition = 0
                }
            }
        }
    }
    
    func cutFish() {
        guard fishCuts.count < 2 && timeRemaining > 0 && !isCutting else { return }
        
        // Start cutting animation
        isCutting = true
        isKnifeMoving = false
        
        // Add cut at current knife position
        fishCuts.append(knifePosition)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCutting = false
            
            if fishCuts.count == 2 {
                // Calculate total score after both cuts are made
                calculateFinalScore()
                
                // Game completed - show cut result
                showCutResult = true
                gameStatus = "Perfect! Fish cut into 3 pieces!"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showScore = true
                    knifeTimer?.invalidate()
                }
            } else {
                // Continue for next cut
                gameStatus = "Great! One more cut needed!"
                isKnifeMoving = true
            }
        }
    }
    
    func calculateFinalScore() {
        // Calculate accuracy for both cuts
        let cut1Accuracy = abs(fishCuts[0] - fishWidth/3)
        let cut2Accuracy = abs(fishCuts[1] - 2*fishWidth/3)
        
        // Calculate average accuracy (lower is better)
        let averageAccuracy = (cut1Accuracy + cut2Accuracy) / 2
        
        // Convert to score: max 100 points, decreases with distance from target
        // Perfect cut (0 distance) = 100 points
        // Maximum penalty distance = fishWidth/6 (50 pixels) = 0 points
        let maxPenaltyDistance: CGFloat = fishWidth/6
        let accuracyRatio = min(averageAccuracy / maxPenaltyDistance, 1.0)
        
        score = max(0, Int(100 * (1.0 - accuracyRatio)))
    }
    
    func endGame() {
        knifeTimer?.invalidate()
        isKnifeMoving = false
        if fishCuts.count < 2 {
            gameStatus = "Time's up! Try again!"
        }
        showScore = true
    }
    
    func resetGame() {
        timeRemaining = 40
        fishCuts = []
        score = 0
        gameStatus = "Tap to cut the fish!"
        showScore = false
        showCutResult = false
        isCutting = false
        knifePosition = 0
        currentFishIndex = Int.random(in: 1...5) // Random fish dari fish1-fish5
        isKnifeMoving = true
        startKnifeMovement()
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
    ContentView()
}
