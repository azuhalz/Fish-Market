//
//  NavigationHintView.swift
//  FishCutting
//
//  Created by William Kesuma on 15/07/25.
//
import SwiftUI
import SwiftData

struct NavigationHintView: View {
    @State private var isPlaying = false
    @Query var trackers: [SatisfiedTracker]
    @StateObject private var audioManager = AudioManager.shared
    
    var total: Int {
        trackers.first?.totalSatisfied ?? 0
    }
    
    var body: some View {
        ZStack {
            // Bottom layer: game content
            ContentView(isPlaying: $isPlaying)
            
            if !isPlaying {
                // Middle layer: semi-transparent overlay
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .ignoresSafeArea()
                
                // Top layer: play UI
                VStack {
                    Text("Tap To Cut The Fish")
                        .lineSpacing(10)
                        .font(.custom("LilitaOne", size: 40))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            isPlaying = true
                            audioManager.stopBackgroundMusic()
                            audioManager.playBackgroundMusic()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationHintView()
}
