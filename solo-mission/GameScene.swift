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

struct PhysicsCategories {
    static let None:    UInt32 = 0      // 0
    static let Player:  UInt32 = 0b1    // 1
    static let Bullet:  UInt32 = 0b10   // 2
    static let Enemy:   UInt32 = 0b100  // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static let scale: CGFloat = 1.0 - (1.0 / UIScreen.main().scale)
    
    private let space: SpaceNode?
    private let player: SpaceShip = SpaceShip()
    
    private var lastUpdate: TimeInterval = 0.0
    private var calculateCollisions = true
    
    // MARK: private
    
    func gameZPosition(zPosition: CGFloat) -> CGFloat {
        return zPosition + 10.0
    }
    
    // MARK: physics
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // organise bodies by category bitmask order
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // player hits enemy
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            if let node = body2.node {
                self.nodeExplode(node)
            }
            if let node = body1.node {
                self.nodeExplode(node, run: {
                    self.isPaused = true
                })
            }
        }
        
        // bullet hits enemy
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            if let node = body2.node {
                // if enemy is out of the screen, do nothing
                if node.position.y >= self.size.height {
                    return
                }
                // otherwise enemy explodes ...
                self.nodeExplode(node)
            }
            // ... and bullet disappear
            body1.node?.removeFromParent()
        }
        
    }
    
    // MARK: implementation
    
    override init(size: CGSize) {
        space = SpaceNode(size: size)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // create the life the universe and everything (42)
        space!.size = self.size
        space!.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        space!.zPosition = 0
        self.addChild(space!)
                
        // create the player ship
        player.setScale(GameScene.scale)
        player.position = CGPoint(x: self.size.width/2, y: -player.size.height)
        player.zPosition = self.gameZPosition(zPosition: 2)
        self.addChild(player)
        
        DispatchQueue.main.after(when: .now() + 0.5) {
            // player appear
            let playerAppear = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.3)
            self.player.run(playerAppear)
            // pop enemies
            self.startSpawningEnemies()
            // nyan nyan nyan
            self.startNyaning()
        }

    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate != 0 {
            let deltaT = currentTime - lastUpdate
            space!.update(deltaT: deltaT)
        }
        lastUpdate = currentTime
    }
    
    // MARK: shooting management
    
    private func nodeExplode(_ node: SKNode!, run: (()->()) = {}) {
        
        let boom = SKSpriteNode(imageNamed: "explosion")
        boom.setScale(0.0)
        boom.zPosition = self.gameZPosition(zPosition: 4)
        boom.position = node.position
        self.addChild(boom)
        
        node.removeFromParent()
        
        let boomAppear = SKAction.scale(to: GameScene.scale, duration: 0.2)
        let boomFade = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let boomAction = SKAction.group([boomAppear, boomFade])
        boom.run(boomAction) {
            boom.removeFromParent()
            run()
        }
        
    }
    
    private func fireBullet() {
        let bullet: SKSpriteNode = player.fireBullet(destinationY: self.size.height)
        self.addChild(bullet)
        bullet.name = "bullet"
    }
    
    // MARK: spawn objects
    
    func spawnNyanCat() {
        
        let cat = NyanCat()
        cat.setScale(GameScene.scale)
        let from = CGPoint(x: -cat.size.width, y: self.size.height / 2.0)
        let to = CGPoint(x: self.size.width + cat.size.width, y: from.y)
        cat.position = from
        
        self.addChild(cat)
        cat.nyanNyanNyan(from: from, to: to)
        
    }
    
    func spawnEnemy() {
        
        func random() -> CGFloat {
            return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        }
        
        func random(min: CGFloat, max: CGFloat) -> CGFloat {
            return random() * (max - min) + min
        }
        
        let randomXStart = random(min: -40, max: self.size.width + 40)
        let yStart = self.size.height + 200.0
        
        let randomXEnd = random(min: -40, max: self.size.width + 40)
        let yEnd: CGFloat = -100.0
        
        let enemy = EnemyNode()
        enemy.name = "enemy"
        enemy.setScale(GameScene.scale)
        enemy.move = (arc4random() % 2 == 0 ? .Straight : .Curvy)
        enemy.zPosition = self.gameZPosition(zPosition: 3)
        self.addChild(enemy)
        
        enemy.move(from: CGPoint(x: randomXStart, y: yStart),
                   to: CGPoint(x: randomXEnd, y: yEnd))
        
    }
    
    func startSpawningEnemies() {
        let waitAction = SKAction.wait(forDuration: 4)
        let spawnAction = SKAction.run {
            self.spawnEnemy()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func startNyaning() {
        let waitAction = SKAction.wait(forDuration: 5)
        let spawnAction = SKAction.run {
            self.spawnNyanCat()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run(SKAction.repeatForever(sequence))
    }
    
    // MARK: handle touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.isPaused {
            return
        }
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previous = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previous.x
            
            var x = player.position.x + amountDragged
            x = max(player.size.width / 2, x)
            x = min(self.size.width - player.size.width / 2, x)
            player.position.x = x
            
        }
        
    }
    
}
