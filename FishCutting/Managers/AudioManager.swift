import AVFoundation

class WilkesAudioPlayer:ObservableObject {
    static var itCanBeAnything = WilkesAudioPlayer()
    
}
//
//var audioManager2 = AudioManager()
//
//var audioManager3 = WilkesAudioPlayer.shared
//
//var audioManager4 = WilkesAudioPlayer.shared


class AudioManager: ObservableObject {
    static var shared = AudioManager()
    private var cutAudioPlayer: AVAudioPlayer?
    private var fishAudioPlayer: AVAudioPlayer?
    var bgAudioPlayer: AVAudioPlayer?
    private var plusOnePlayer: AVAudioPlayer?
    private var timesUpPlayer: AVAudioPlayer?
    
    
    func playBackgroundMusic() {
        guard let soundURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Background music file not found")
            return
        }

        if bgAudioPlayer == nil {
            do {
                bgAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                bgAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
                bgAudioPlayer?.prepareToPlay()
                bgAudioPlayer?.volume = 0.5
                bgAudioPlayer?.play()
                print("🎵 Background music started")
            } catch {
                print("Failed to play background music: \(error.localizedDescription)")
            }
        } else if bgAudioPlayer?.isPlaying == false {
            bgAudioPlayer?.play()
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
    
    func playTimesUpSound() {
        guard let soundURL = Bundle.main.url(forResource: "Times_up", withExtension: "mp3") else {
            print("❌ Times_up.mp3 not found")
            return
        }

        do {
            // If the sound is already playing, stop and reset it
            if let player = timesUpPlayer, player.isPlaying {
                player.stop()
                player.currentTime = 0
            }

            timesUpPlayer = try AVAudioPlayer(contentsOf: soundURL)
            timesUpPlayer?.prepareToPlay()
            timesUpPlayer?.volume = 1.0
            timesUpPlayer?.numberOfLoops = 0
            timesUpPlayer?.play()

            print("🔊 Times Up sound is playing (duration: \(timesUpPlayer?.duration ?? 0))")
        } catch {
            print("❌ Failed to play Times Up sound: \(error.localizedDescription)")
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
