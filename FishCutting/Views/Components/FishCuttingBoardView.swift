import SwiftUI

struct FishCuttingBoardView: View {
    @Binding var showDashedLines: Bool
    
    let showCutResult: Bool
    let currentFishIndex: Int
    let fishRotation: Double
    let fishOffsetX: CGFloat
    let fishVerticalOffset: CGFloat
    let requestedCuts: Int
    let fishCuts: [CGFloat]
    let hasPlayedFishSound: Bool
    let onFishAppear: () -> Void
    let onFishIndexChange: () -> Void
    
    var body: some View {
        ZStack {
            if !showCutResult {
                Image("cut_board")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 330, height: 165)
                
                ZStack {
                    Image("fish\(currentFishIndex)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: GameConstants.fishWidth, height: GameConstants.fishHeight)
                        .rotationEffect(.degrees(fishRotation))
                        .offset(x: fishOffsetX, y: -5)
                        .onAppear {
                            onFishAppear()
                            
                            // Delay showing the dashed lines
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showDashedLines = true
                                }
                            }
                        }
                        .onChange(of: currentFishIndex) { _ in
                            onFishIndexChange()
                        }
                    
                    // Dash lines for the cuts
                    if showDashedLines {
                        ForEach(1..<requestedCuts, id: \.self) { i in
                            let x = GameConstants.fishWidth * CGFloat(i) / CGFloat(requestedCuts)
                            DashedLine()
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .frame(width: 2, height: GameConstants.fishHeight)
                                .offset(x: x - GameConstants.fishWidth/2)
                        }
                    }
                    
                    // Cut marks
                    ForEach(Array(fishCuts.enumerated()), id: \.offset) { index, cutPosition in
                        Rectangle()
                            .fill(Color.black)
                            .opacity(0.3)
                            .frame(width: 3, height: GameConstants.fishHeight)
                            .offset(x: cutPosition - GameConstants.fishWidth/2)
                    }
                }
            } else {
                splitFishView()
            }
        }
    }
    
    @ViewBuilder
    private func splitFishView() -> some View {
        HStack(spacing: 5) {
            ForEach(1...requestedCuts, id: \.self) { i in
                Image("fish_cut_\(i)")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 165)
    }
}

#Preview {
    @State var showDashedLines = false
    
    VStack {
        // Preview with fish and cutting board
        FishCuttingBoardView(
            showDashedLines: $showDashedLines,
            showCutResult: false,
            currentFishIndex: 1,
            fishRotation: 5.0,
            fishOffsetX: 0,
            fishVerticalOffset: 0,
            requestedCuts: 3,
            fishCuts: [80, 150],
            hasPlayedFishSound: false,
            onFishAppear: {},
            onFishIndexChange: {}
        )
        .padding()
        
        Divider()
        
        // Preview with cut result
        FishCuttingBoardView(
            showDashedLines: $showDashedLines,
            showCutResult: true,
            currentFishIndex: 1,
            fishRotation: 0,
            fishOffsetX: 0,
            fishVerticalOffset: 0,
            requestedCuts: 3,
            fishCuts: [],
            hasPlayedFishSound: true,
            onFishAppear: {},
            onFishIndexChange: {}
        )
        .padding()
    }
    .background(Color.yellow.opacity(0.3))
}
