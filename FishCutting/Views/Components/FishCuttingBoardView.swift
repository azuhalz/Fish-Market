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
        GeometryReader { geo in
            ZStack {
                if !showCutResult {
                    originalFishView(width: geo.size.width)
                } else {
                    splitFishView(width: geo.size.width)
                }
            }
        }
    }
    
    @ViewBuilder
    private func originalFishView(width: CGFloat) -> some View {
        ZStack {
            Image("cut_board")
                .resizable()
                .scaledToFit()
                .frame(width: 330, height: 165)
                .offset(y: 120)
            
            ZStack {
                Image("fish\(currentFishIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: GameConstants.fishWidth, height: GameConstants.fishHeight)
                    .rotationEffect(.degrees(fishRotation))
                    .offset(x: fishOffsetX, y: 120 + fishVerticalOffset) // Added fishVerticalOffset here too
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
                
                if showDashedLines {
                    ForEach(1..<requestedCuts, id: \.self) { i in
                        let x = GameConstants.fishWidth * CGFloat(i) / CGFloat(requestedCuts)
                        DashedLine()
                            .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .frame(width: 2, height: GameConstants.fishHeight - 15)
                            .offset(x: x - GameConstants.fishWidth/2, y: 120)
                    }
                }
                
                ForEach(Array(fishCuts.enumerated()), id: \.offset) { index, cutPosition in
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.3)
                        .frame(width: 3, height: GameConstants.fishHeight - 15)
                        .offset(x: cutPosition - GameConstants.fishWidth/2, y: 120)
                }
            }
        }.frame(width: width)
    }
    
    private func splitFishView(width: CGFloat) -> some View {
        let sortedCuts = ([0] + fishCuts + [GameConstants.fishWidth]).sorted()
        let totalPieces = sortedCuts.count - 1
        let spacing: CGFloat = 0.5
        let pieceWidth: CGFloat = 20
        
        let totalWidth = CGFloat(totalPieces) * pieceWidth + CGFloat(totalPieces - 1) * spacing
        let startX = (width - totalWidth) / 2
        
        return ZStack {
            Image("cut_board")
                .resizable()
                .scaledToFit()
                .frame(width: 330, height: 165)
                .offset(y: 113)
            
            ForEach(0..<totalPieces, id: \.self) { i in
                let left = sortedCuts[i]
                let right = sortedCuts[i + 1]
                let segmentWidth = right - left
                let maskCenter = (left + right) / 2
                
                if segmentWidth >= 10 {
                    let xOffset = startX + CGFloat(i) * (pieceWidth + spacing)
                    
                    Image("fish\(currentFishIndex)_dead")
                        .resizable()
                        .scaledToFit()
                        .frame(width: GameConstants.fishWidth, height: GameConstants.fishHeight)
                        .mask(
                            Rectangle()
                                .frame(width: segmentWidth + 2, height: GameConstants.fishHeight)
                                .offset(x: maskCenter - GameConstants.fishWidth / 2)
                        )
                        .offset(x: fishOffsetX + 10 + xOffset - width / 2, y: fishVerticalOffset + 103)
                        .opacity(Double(1 - abs(fishOffsetX / 400)))
                }
            }
        }
        .frame(width: width, height: GameConstants.fishHeight + 50)
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
