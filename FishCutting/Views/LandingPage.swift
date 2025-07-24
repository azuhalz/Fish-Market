import SwiftUI
import SwiftData

struct LandingPage: View {
    @Query var trackers: [SatisfiedTracker]
    @State private var showHintView = false
    
    var highScore: Int {
        trackers.map { $0.totalSatisfied }.max() ?? 0
    }

    var body: some View {
        ZStack {
            Image("background_landing_page")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
            
            if showHintView {
                NavigationHintView()
            } else {
                VStack(spacing: 20) {
                    Image("logo")

                    Button {
                        showHintView = true
                    } label: {
                        VStack {
                            Image("play_button")
                                .resizable()
                                .frame(width: 150, height: 150)
//                          Text("Play")
//                          .font(.custom("LilitaOne", size: 50))
//                          .foregroundColor(Color(hex: "#1794AD"))
//                           Text("Highscore: \(highScore)")
//                          .font(.custom("LilitaOne", size: 32))
//                          .foregroundColor(Color(hex: "#1794AD"))
                        }
                        .padding(.bottom, 120)
                    }
                }
            }
        }
    }
}

#Preview {
    LandingPage()
}

