//
//  EndingPage.swift
//  FishCutting
//
//  Created by William Kesuma on 17/07/25.
//

import SwiftUI

struct GameOverView: View {
    var Highscore: Int
    var satisfiedCount: Int //
    var onPlayAgain: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea() // semi-transparent background

            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Highscore: \(Highscore)")
                    .font(.title2)
                    .foregroundColor(.white)

                Text("Satisfied Customers: \(satisfiedCount)")
                    .font(.title3)
                    .foregroundColor(.white)

                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.yellow.opacity(1))
            .cornerRadius(20)
            .padding()
        }
    }
}

#Preview {
    GameOverView(Highscore: 100, satisfiedCount: 50, onPlayAgain: {})
}
