import SwiftUI

struct GameHeaderView: View {
    let timeRemaining: Int
    let currentHighScore: Int
    let satisfiedCount: Int
    let showPlusOne: Bool
    let plusOneOffset: CGFloat
    
    var body: some View {
        HStack {
            Text("Highscore:\(currentHighScore)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .cornerRadius(10)
            
            Spacer()
            
            Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.orange)
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
    }
}

#Preview {
    GameHeaderView(
        timeRemaining: 45,
        currentHighScore: 12,
        satisfiedCount: 8,
        showPlusOne: true,
        plusOneOffset: -20
    )
    .background(Color.yellow.opacity(0.3))
}
