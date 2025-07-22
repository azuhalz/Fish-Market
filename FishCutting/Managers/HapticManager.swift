import CoreHaptics
import SwiftUI

class HapticManager: ObservableObject {
    var hapticEngine: CHHapticEngine?
    
    func prepareHaptics() {
        print("🛠 prepareHaptics() dipanggil")
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Haptics not supported on this device")
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            print("✅ hapticEngine berhasil dimulai")
        } catch {
            print("❌ Gagal memulai hapticEngine: \(error.localizedDescription)")
        }
    }
    
    func playHapticCut() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let duration: TimeInterval = 0.3
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic feedback: \(error.localizedDescription)")
        }
    }
    
    func playUnsatisfiedHaptic() {
        print("🔔 playUnsatisfiedHaptic (UIKit) dijalankan")

        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()

        // Tambahkan getaran kedua dan ketiga untuk memperkuat efek
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred()
        }
    }

    
    func stopHaptics() {
        hapticEngine?.stop()
    }
}
