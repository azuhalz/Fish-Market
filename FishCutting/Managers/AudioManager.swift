import AVFoundation

class AudioManager: ObservableObject {
    private var cutAudioPlayer: AVAudioPlayer?
    private var fishAudioPlayer: AVAudioPlayer?
    var bgAudioPlayer: AVAudioPlayer?
    private var plusOnePlayer: AVAudioPlayer?
    
    func playBackgroundMusic() {
        guard let soundURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Background music file not found")
            return
        }
        
        do {
            bgAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            bgAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            bgAudioPlayer?.play()
        } catch {
            print("Failed to play background music: \(error.localizedDescription)")
        }
    }
    
    func playCutSound() {
        guard let soundURL = Bundle.main.url(forResource: "cut_sound", withExtension: "wav") else {
            print("Cut sound file not found")
            return
        }
        
        do {
            cutAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            cutAudioPlayer?.play()
        } catch {
            print("Failed to play cut sound: \(error.localizedDescription)")
        }
    }
    
    func playPlusOneSound() {
        guard let soundURL = Bundle.main.url(forResource: "point_up", withExtension: "wav") else {
            print("Plus one sound file not found")
            return
        }
        
        do {
            plusOnePlayer = try AVAudioPlayer(contentsOf: soundURL)
            plusOnePlayer?.play()
        } catch {
            print("Failed to play plus one sound: \(error.localizedDescription)")
        }
    }
    
    func stopFishSound() {
        fishAudioPlayer?.stop()
    }
    
    func stopBackgroundMusic() {
        bgAudioPlayer?.stop()
    }
    
    func stopAllSounds() {
        cutAudioPlayer?.stop()
        fishAudioPlayer?.stop()
        bgAudioPlayer?.stop()
        plusOnePlayer?.stop()
    }
}
