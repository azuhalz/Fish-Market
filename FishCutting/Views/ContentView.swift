import SwiftUI

struct ContentView: View {
    @Binding var isPlaying: Bool
    
    var body: some View {
        FishCuttingGameView(isPlaying: $isPlaying)
    }
}

#Preview {
    ContentView(isPlaying: .constant(false))
}

