import SwiftUI
import SwiftData

struct LandingPage: View {
    @Query var trackers: [SatisfiedTracker]
    @State private var showHintView = false

    var total: Int {
        trackers.first?.totalSatisfied ?? 0
    }

    var body: some View {
        ZStack {
            Image("background_landing_page")
                .ignoresSafeArea(edges: .all)
            
            if showHintView {
                NavigationHintView()
            } else {
//                Color.yellow.opacity(0.3)
//                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Total satisfied customer: \(total)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)

                    Button {
                        showHintView = true
                    } label: {
                        VStack {
                            Image("play_button")
                                .resizable()
                                .frame(width: 110, height: 110)
                            Text("Play")
                                .font(.custom("Georgia", size: 40))
                                .bold()
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LandingPage()
}

