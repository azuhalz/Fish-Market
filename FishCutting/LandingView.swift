import SwiftUI
import SwiftData

struct LandingView: View {
    @State private var isPlaying = false
    @Query var trackers: [SatisfiedTracker]

    var total: Int {
        trackers.first?.totalSatisfied ?? 0
    }

    var body: some View {
        ZStack{
            Color.yellow.opacity(0.3)
                .ignoresSafeArea()
            
            if isPlaying {
                ContentView(isPlaying: $isPlaying)
            } else {
                VStack(spacing: 20) {
                    Text("Total satisfied customer: \(total)")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Button {
                        isPlaying = true
                    } label: {
                        VStack{
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange.opacity(0.8))
                            Text("Play")
//                                .font(.system(size: 40))
                                .font(.custom("georgia", size: 40))
                                .bold()
                                .foregroundColor(.orange.opacity(0.8))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LandingView()
}
