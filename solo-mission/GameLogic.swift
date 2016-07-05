//
//  GameLogic.swift
//  solo-mission
//
//  Created by Romain ROCHE on 05/07/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import Foundation
import CoreGraphics

protocol GameLogicDelegate: class {
    func scoreDidChange(_ newScore: Int, text: String!)
    func livesDidChange(_ newLives: Int, text: String!)
    func playerDidLose(shouldExplode: Bool)
    func shouldSpawnEnemy(enemySpeedMultiplier: CGFloat)
    func shouldSpawnBonus()
}

class GameLogic: NSObject {

    private static let DefaultNumberOfLives: Int = 3
    private static let DefaultScore: Int = 0
    private static let DefaultEnemiesSpawnInterval: TimeInterval = 4.0
    private static let DefaultEnemiesSpeedMultiplier: CGFloat = 1.0
    
    // MARK: - delegate
    
    weak var delegate: GameLogicDelegate? = nil
    
    // MARK: - score
    
    private(set) var score: Int = GameLogic.DefaultScore {
        didSet {
            delegate?.scoreDidChange(score, text: self.scoreText())
            if score % 3000 == 0 {
                enemiesSpeedMultiplier += 0.1
            } else if score % 1000 == 0 {
                spawnEnemiesInterval = max(0.5, spawnEnemiesInterval - 0.5)
                self.stopSpawningEnemies()
                self.startSpawningEnemies()
            }
        }
    }
    
    func scoreText() -> String! {
        return "SCORE : \(score)"
    }
    
    // MARK: - lives
    
    private(set) var lives: Int = GameLogic.DefaultNumberOfLives {
        didSet {
            delegate?.livesDidChange(lives, text: self.livesText())
            if lives == 0 {
                delegate?.playerDidLose(shouldExplode: false)
            }
        }
    }
    
    func livesText() -> String! {
        return "LIVES : \(lives)"
    }
    
    // MARK: - enemies
    
    private var spawnEnemiesInterval: TimeInterval = GameLogic.DefaultEnemiesSpawnInterval
    private var enemiesSpeedMultiplier: CGFloat = GameLogic.DefaultEnemiesSpeedMultiplier
    private var enemiesSpawner: Timer? = nil
    
    private func spawEnemy(_ timer: Timer) {
        delegate?.shouldSpawnEnemy(enemySpeedMultiplier: enemiesSpeedMultiplier)
    }
    
    private func startSpawningEnemies() {
        enemiesSpawner = Timer.scheduledTimer(timeInterval: spawnEnemiesInterval,
                                              target: self,
                                              selector: Selector(("spawEnemy:")),
                                              userInfo: nil,
                                              repeats: true)
    }
    
    private func stopSpawningEnemies() {
        enemiesSpawner?.invalidate()
        enemiesSpawner = nil
    }
    
    // MARK: - bonus
    
    private var bonusSpawner: Timer? = nil
    
    private func spawBonus(_ timer: Timer) {
        delegate?.shouldSpawnBonus()
        self.startSpawningBonus()
    }
    
    private func startSpawningBonus() {
        let waitTime = random(min: 50.0, max: 120.0)
        bonusSpawner = Timer.scheduledTimer(timeInterval: TimeInterval(waitTime),
                                              target: self,
                                              selector: Selector(("spawBonus:")),
                                              userInfo: nil,
                                              repeats: false)
    }
    
    private func stopSpawningBonus() {
        bonusSpawner?.invalidate()
        bonusSpawner = nil
    }
    
    // MARK: - implementation
    
    func gameDidStart() {
        
        score = GameLogic.DefaultScore
        lives = GameLogic.DefaultNumberOfLives
        spawnEnemiesInterval = GameLogic.DefaultEnemiesSpawnInterval
        enemiesSpeedMultiplier = GameLogic.DefaultEnemiesSpeedMultiplier
        
        self.stopSpawningEnemies()
        self.startSpawningEnemies()
        
        self.stopSpawningBonus()
        self.startSpawningBonus()
        
    }
    
    func gameDidStop() {
        self.stopSpawningEnemies()
        self.stopSpawningBonus()
    }
    
    func enemyKilled() {
        self.score += 100
    }
    
    func enemyEscaped() {
        self.lives -= 1
    }
    
    func enemyTouchesPlayer() {
        delegate?.playerDidLose(shouldExplode: true)
    }
    
}
