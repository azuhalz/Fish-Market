//
//  EndingPage.swift
//  FishCutting
//
//  Created by William Kesuma on 17/07/25.
//

import SwiftUI

struct GameOverView: View {
    let currentScore: Int
    let satisfiedCount: Int
    let previousHighScore: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            let isNewRecord = satisfiedCount > previousHighScore
            
            Text("GAME OVER")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if isNewRecord {
                Text("NEW HIGHSCORE: \(satisfiedCount)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            } else {
                Text("HIGHSCORE: \(previousHighScore)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text("YOUR SCORE: \(satisfiedCount)")
                .font(.title3)
                .foregroundColor(.white)
            
            Button("Play Again") {
                onRestart()
            }
            .font(.title2)
            .padding()
            .background(Color.white)
            .foregroundColor(.orange)
            .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.8))
        )
    }
}

#Preview {
    GameOverView(
        currentScore: 12,
        satisfiedCount: 15,
        previousHighScore: 10,
        onRestart: {
            print("Restart tapped")
        }
    )
    .padding()
    .background(Color.black)
}
