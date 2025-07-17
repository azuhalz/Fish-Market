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
            if showHintView {
                NavigationHintView()
            } else {
                Color.yellow.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Total satisfied customer: \(total)")
                        .font(.title)
                        .foregroundColor(.orange)

                    Button {
                        showHintView = true
                    } label: {
                        VStack {
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange.opacity(0.8))
                            Text("Play")
                                .font(.custom("Georgia", size: 40))
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
    LandingPage()
}

