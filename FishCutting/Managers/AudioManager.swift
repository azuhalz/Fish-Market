import AVFoundation

class AudioManager: ObservableObject {
    static var shared = AudioManager()
    private var cutAudioPlayer: AVAudioPlayer?
    private var fishAudioPlayer: AVAudioPlayer?
    var bgAudioPlayer: AVAudioPlayer?
    private var plusOnePlayer: AVAudioPlayer?
    private var timesUpPlayer: AVAudioPlayer?
    private var landingAudioPlayer: AVAudioPlayer?
    private var unsatisfiedPlayer: AVAudioPlayer?
    
    func playBackgroundMusic() {
        guard let soundURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("❌ Background music file not found")
            return
        }

        if bgAudioPlayer == nil {
            do {
                bgAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                bgAudioPlayer?.numberOfLoops = 0 // Loop indefinitely
                bgAudioPlayer?.prepareToPlay()
                bgAudioPlayer?.volume = 0.5
                bgAudioPlayer?.play()
                print("✅ Background music started")
            } catch {
                print("❌ Failed to play background music: \(error.localizedDescription)")
            }
        } else if bgAudioPlayer?.isPlaying == false {
            bgAudioPlayer?.play()
        }
    }

    
    func playCutSound() {
        guard let soundURL = Bundle.main.url(forResource: "cut_sound", withExtension: "wav") else {
            print("❌ Cut sound file not found")
            return
        }
        
        do {
            cutAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            cutAudioPlayer?.play()
        } catch {
            print("❌ Failed to play cut sound: \(error.localizedDescription)")
        }
    }

    
    func playPlusOneSound() {
        guard let soundURL = Bundle.main.url(forResource: "satisfied_sound", withExtension: "wav") else {
            print("❌ Plus one sound file not found")
            return
        }
        
        do {
            plusOnePlayer = try AVAudioPlayer(contentsOf: soundURL)
            plusOnePlayer?.play()
        } catch {
            print("❌ Failed to play plus one sound: \(error.localizedDescription)")
        }
    }
    
    func playTimesUpSound() {
        guard let soundURL = Bundle.main.url(forResource: "Times_up", withExtension: "mp3") else {
            print("❌ Times Up file not found")
            return
        }

        do {
            if let player = timesUpPlayer, player.isPlaying {
                player.stop()
                player.currentTime = 0
            }

            timesUpPlayer = try AVAudioPlayer(contentsOf: soundURL)
            timesUpPlayer?.prepareToPlay()
            timesUpPlayer?.volume = 1.0
            timesUpPlayer?.numberOfLoops = 0
            timesUpPlayer?.play()

            print("✅ Times up music started")
        } catch {
            print("❌ Failed to play Times Up sound: \(error.localizedDescription)")
        }
    }

    func playLandingMusic() {
        guard let soundURL = Bundle.main.url(forResource: "landing_music", withExtension: "mp3") else {
            print("❌ Landing background music file not found")
            return
        }

        if landingAudioPlayer == nil {
            do {
                landingAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                landingAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
                landingAudioPlayer?.prepareToPlay()
                landingAudioPlayer?.volume = 0.7
                landingAudioPlayer?.play()
                print("✅ Landing background music started")
            } catch {
                print("❌ Failed to play landing background music: \(error.localizedDescription)")
            }
        } else if landingAudioPlayer?.isPlaying == false {
            landingAudioPlayer?.play()
        }
    }
    
    func playUnsatisfiedSound() {
            // Pastikan nama file dan ekstensi (wav/mp3) sesuai dengan file Anda
            guard let soundURL = Bundle.main.url(forResource: "unsatisfied_sound", withExtension: "wav") else {
                print("❌ Unsatisfied sound file not found")
                return
            }
            
            do {
                unsatisfiedPlayer = try AVAudioPlayer(contentsOf: soundURL)
                unsatisfiedPlayer?.play()
            } catch {
                print("❌ Failed to play unsatisfied sound: \(error.localizedDescription)")
            }
        }
    
    func stopFishSound() {
        fishAudioPlayer?.stop()
    }
    
    func stopBackgroundMusic() {
        bgAudioPlayer?.stop()
    }
    
    func stopLandingMusic() {
        landingAudioPlayer?.stop()
    }
    
    func stopAllSounds() {
        cutAudioPlayer?.stop()
        fishAudioPlayer?.stop()
        bgAudioPlayer?.stop()
        plusOnePlayer?.stop()
    }
}
