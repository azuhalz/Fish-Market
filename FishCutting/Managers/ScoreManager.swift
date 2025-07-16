import Foundation

class ScoreManager: ObservableObject {
    private let highScoreKey = "highscore"
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    func updateHighScore(_ newScore: Int) {
        let currentHighScore = getHighScore()
        if newScore > currentHighScore {
            UserDefaults.standard.set(newScore, forKey: highScoreKey)
        }
    }
    
    func resetHighScore() {
        UserDefaults.standard.removeObject(forKey: highScoreKey)
    }
}
