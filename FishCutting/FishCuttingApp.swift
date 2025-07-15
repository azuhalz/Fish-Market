//
//  FishCuttingApp.swift
//  FishCutting
//
//  Created by Ahmad Zuhal Zhafran on 10/07/25.
//

import SwiftUI

@main
struct FishCuttingApp: App {
    var body: some Scene {
        WindowGroup {
            LandingView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: SatisfiedTracker.self)
    }
}
