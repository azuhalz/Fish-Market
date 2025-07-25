import SwiftUI

struct GameHeaderView: View {
    let timeRemaining: Int
    let currentHighScore: Int
    let satisfiedCount: Int
    let showPlusOne: Bool
    let plusOneOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let sideWidth = geometry.size.width * 0.3 // Equal visual space for left and right

            HStack {
                // Score (left)
                ZStack {
                    TextStroke(
                        text: "Score: \n \(satisfiedCount)",
                        width: 1.5,
                        color: Color(hex: "#966631")
                    )
                    .font(.custom("LilitaOne", size: 19.4))
                    .foregroundColor(.white)
                    .padding(10)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                    .offset(y: -50)

                    if showPlusOne {
                        Text("+1")
                            .font(.custom("LilitaOne", size: 19.4))
                            .foregroundColor(.white)
                            .offset(y: plusOneOffset)
                            .transition(.opacity)
                    }
                }
                .frame(width: sideWidth)

                // Timer (center)
                ZStack {
                    Image("timer")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .offset(x: -10, y: -50)

                    Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                        .font(.custom("Micro5-Regular", size: 36))
                        .foregroundColor(.black)
                        .offset(x: -10, y: -50)
                }
                .frame(maxWidth: .infinity)
                .offset(x: 10) // ✅ subtle shift to the right for visual centering

                // High Score (right)
                ZStack {
                    TextStroke(
                        text: "Highscore:\n\(currentHighScore)",
                        width: 1.5,
                        color: Color(hex: "#966631")
                    )
                    .font(.custom("LilitaOne", size: 19.4))
                    .foregroundColor(.white)
                    .lineSpacing(4) // ✅ Better line spacing
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .offset(y: -50)
                }
                .frame(width: sideWidth)
            }
        }
        .frame(height: 150)
        .padding(20)
    }
}

struct TextStroke: View {
    let text: String
    let width: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            ZStack {
                Text(text).offset(x: width, y: width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y: width)
                Text(text).offset(x: width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

#Preview {
    GameHeaderView(
        timeRemaining: 45,
        currentHighScore: 99,
        satisfiedCount: 99,
        showPlusOne: true,
        plusOneOffset: -20
    )
    .background(Color.yellow.opacity(0.3))
}

