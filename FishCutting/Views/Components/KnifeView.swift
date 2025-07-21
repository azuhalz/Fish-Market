import SwiftUI

struct KnifeView: View {
    let isKnifeMoving: Bool
    let isCutting: Bool
    let showCutResult: Bool
    let knifePosition: CGFloat
    
    var body: some View {
        ZStack {
            // Show knife when moving or cutting, but HIDE when showing cut results
            if (isKnifeMoving || isCutting) && !showCutResult {
                Image("knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 300)
                    .offset(x: knifePosition - GameConstants.fishWidth/2, y: 110)
                    .animation(.none, value: knifePosition)
            }
        }
    }
}

#Preview {
    VStack {
        // Preview with knife visible (moving)
        KnifeView(
            isKnifeMoving: true,
            isCutting: false,
            showCutResult: false,
            knifePosition: 100
        )
        .frame(height: 200)
        
        Divider()
        
        // Preview with knife cutting
        KnifeView(
            isKnifeMoving: false,
            isCutting: true,
            showCutResult: false,
            knifePosition: 150
        )
        .frame(height: 200)
        
        Divider()
        
        // Preview with knife HIDDEN (showing cut results)
        KnifeView(
            isKnifeMoving: false,
            isCutting: false,
            showCutResult: true,
            knifePosition: 150
        )
        .frame(height: 200)
        .overlay(
            Text("Cut results showing - knife should be hidden")
                .foregroundColor(.red)
        )
    }
    .background(Color.yellow.opacity(0.3))
}
