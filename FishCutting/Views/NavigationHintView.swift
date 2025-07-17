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
                    .fill(Color.black.opacity(0.9))
                    .ignoresSafeArea()
                
                // Top layer: play UI
                VStack {
                    Text("Tap To Cut The Fish")
                        .lineSpacing(10)
                        .font(.custom("Georgia", size: 20))
                        .bold()
                        .foregroundColor(.white)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isPlaying = true
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
