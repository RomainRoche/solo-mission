//
//  GameScene.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 23/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound: SKAction = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    let scale: CGFloat = 1.0 - (1.0 / UIScreen.main().scale)
    
    override func didMove(to view: SKView) {
        
        // create the space!!
        let space: SpaceNode = SpaceNode()
        space.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        space.zPosition = 0
        self.addChild(space)
        space.moveInSpace()
        
        // create the player ship
        player.size = CGSize(width: 88, height: 204)
        player.setScale(scale)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
        
        // spawn enemies
        startSpawningEnemies()

    }
    
    // MARK: shooting management
    
    func fireBullet() {
        
        // create a bullet
        let bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: 25, height: 100)
        bullet.setScale(scale)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.alpha = 0.0
        self.addChild(bullet)
        
        // two actions
        let moveBullet: SKAction = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let appearBullet: SKAction = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        let bulletAnimation: SKAction = SKAction.group([moveBullet, appearBullet])
        let deleteBullet: SKAction = SKAction.removeFromParent()
        
        // sequence of actions
        let bulletSequence: SKAction = SKAction.sequence([bulletSound, bulletAnimation, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    // MARK: spawn enemies
    
    func spawnEnemy() {
        
        func random() -> CGFloat {
            return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        }
        
        func random(min: CGFloat, max: CGFloat) -> CGFloat {
            return random() * (max - min) + min
        }
        
        let randomXStart: CGFloat = random(min: 0, max: self.size.width)
        let yStart: CGFloat = self.size.height - 200
        
        let randomXEnd: CGFloat = random(min: 0, max: self.size.width)
        let yEnd: CGFloat = -100
        
        let enemy: EnemyNode = EnemyNode()
        enemy.position = CGPoint(x: randomXStart, y: yStart)
        enemy.setScale(scale)
        self.addChild(enemy)
        
        let moveAction: SKAction = SKAction.move(to: CGPoint(x: randomXEnd, y: yEnd), duration: 5.0)
        let removeAction: SKAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        
        enemy.run(sequence)
        
        
    }
    
    func startSpawningEnemies() {
        let waitAction: SKAction = SKAction.wait(forDuration: 8)
        let spawnAction: SKAction = SKAction.run { 
            self.spawnEnemy()
        }
        let sequence: SKAction = SKAction.sequence([waitAction, spawnAction])
        self.run(SKAction.repeatForever(sequence))
    }
    
    // MARK: handle touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch: CGPoint = touch.location(in: self)
            let previous:CGPoint = touch.previousLocation(in: self)
            let amountDragged: CGFloat = pointOfTouch.x - previous.x
            
            var x: CGFloat = player.position.x + amountDragged
            x = max(player.size.width / 2, x)
            x = min(self.size.width - player.size.width / 2, x)
            player.position.x = x
            
        }
        
    }
    
}
