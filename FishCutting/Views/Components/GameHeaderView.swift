import SwiftUI

struct GameHeaderView: View {
    let timeRemaining: Int
    let currentHighScore: Int
    let satisfiedCount: Int
    let showPlusOne: Bool
    let plusOneOffset: CGFloat
    
    var body: some View {
        HStack {
            ZStack {
                TextStroke(
                    text: "Highest: \n \(currentHighScore)",
                    width: 2.0,
                    color: Color(hex: "#966631")
                )
                .font(.custom("LilitaOne", size: 24))
                .foregroundColor(.white)
                .padding(10)
                .cornerRadius(10)
                .offset(x: 0, y: -50)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
            
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
        
            Spacer()
            
            ZStack {
                TextStroke(
                    text: "Score: \n \(satisfiedCount)",
                    width: 2.0,
                    color: Color(hex: "#966631")
                )
                .font(.custom("LilitaOne", size: 24))
                .foregroundColor(.white)
                .padding(10)
                .cornerRadius(10)
                .offset(x: 0, y: -50)
                .multilineTextAlignment(.center)
                
                if showPlusOne {
                    Text("+1")
                        .font(.custom("LilitaOne", size: 18))
                        .foregroundColor(.white)
                        .offset(y: plusOneOffset)
                        .transition(.opacity)
                }
            }
        }
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
