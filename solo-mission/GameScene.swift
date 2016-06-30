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
    
    // handles the stars and the background
    private let spaceTexture: SKTexture = SKTexture(image: #imageLiteral(resourceName: "background"))
    private let starsSpeed: TimeInterval = 350.0 // px per seconds
    private let limitY: CGFloat
    private var tilesCount: Int = 0
    
    // update loop
    private var lastUpdate: TimeInterval = 0.0
    
    // background
    private let planet: SKSpriteNode?
    
    // player
    private let godMode = false
    private let player: SpaceShip = SpaceShip()
    
    // MARK: private
    
    private func backgroundZPosition(zPosition: CGFloat) -> CGFloat {
        return zPosition + CGFloat(tilesCount)
    }
    
    private func gameZPosition(zPosition: CGFloat) -> CGFloat {
        return zPosition + 30.0
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
        
        // scroll indexes
        let centerY = (size.height - spaceTexture.size().height) / 2
        limitY = 0.0 - centerY - spaceTexture.size().height
        
        // add a planet to the background
        planet = SKSpriteNode()
        
        // super
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // create the space
        var y = -((size.height - spaceTexture.size().height) / 2)
        let loopCount = Int(ceil((self.size.height / spaceTexture.size().height)))
        for i in 0...loopCount {
            print("adding tile")
            tilesCount += 1
            let tile = SKSpriteNode(imageNamed: "background")
            tile.position = CGPoint(x: self.size.width / 2.0, y: y)
            tile.name = "background"
            tile.zPosition = CGFloat(i)
            self.addChild(tile)
            y += self.spaceTexture.size().height
        }
        
        // create the stars particles
        if let path = Bundle.main().pathForResource("star-rain", ofType: "sks") {
            let rain = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            rain.particlePositionRange.dx = self.size.width
            rain.position = CGPoint(x: self.size.width / 2, y: self.size.height)
            rain.zPosition = self.backgroundZPosition(zPosition: 2)
            self.addChild(rain)
        }
        
        // planet prep work
        self.spawnPlanet()
        self.addChild(planet!)
        
        // create the player ship
        player.setScale(GameScene.scale)
        player.position = CGPoint(x: self.size.width/2, y: -player.size.height)
        player.zPosition = self.gameZPosition(zPosition: 4)
        self.addChild(player)
        if godMode {
            player.physicsBody?.categoryBitMask = PhysicsCategories.None
        }
        
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
            var distance = deltaT * starsSpeed
            var zPos = 0
            
            // move background
            self.enumerateChildNodes(withName: "background") { background, stop in
                background.position.y -= CGFloat(distance)
                background.zPosition = CGFloat(zPos)
                zPos += 1
                if background.position.y < self.limitY {
                    background.position.y += CGFloat(self.tilesCount) * self.spaceTexture.size().height
                }
            }
            
            // move the planet
            distance = deltaT * (starsSpeed * 1.1)
            planet?.position.y -= CGFloat(distance)
            if planet?.position.y < self.limitY {
                self.spawnPlanet()
            }
            
        }
        lastUpdate = currentTime
    }
    
    // MARK: utils
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    // MARK: shooting management
    
    private func nodeExplode(_ node: SKNode!, run: (()->()) = {}) {
        
        let boom = SKSpriteNode(imageNamed: "explosion")
        boom.setScale(0.0)
        boom.zPosition = self.gameZPosition(zPosition: 5)
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
    
    func spawnPlanet() {
        
        // doesn't actually "spawn" since it is always here, but still
        
        let textureIndex = arc4random() % 5
        let texture = SKTexture(imageNamed: "planet\(textureIndex)")
        planet?.texture = texture
        planet?.size = texture.size()
        planet?.setScale(self.random(min: 1.0, max: 3.0))
        
        let randomY = self.random(min: 600.0, max: 5000.0)
        planet?.position.y = self.size.height + randomY
        planet?.position.x = random(min: 10.0, max: self.size.width - 10.0)
        
        planet?.zPosition = backgroundZPosition(zPosition: 1)
        
    }
    
    func spawnEnemy() {
        
        let randomXStart = random(min: -40, max: self.size.width + 40)
        let yStart = self.size.height + 200.0
        
        let randomXEnd = random(min: -40, max: self.size.width + 40)
        let yEnd: CGFloat = -100.0
        
        let enemy = EnemyNode()
        enemy.name = "enemy"
        enemy.setScale(GameScene.scale)
        enemy.move = (arc4random() % 2 == 0 ? .Straight : .Curvy)
        enemy.zPosition = self.gameZPosition(zPosition: 5)
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
    
    func spawnNyanCat() {
        
        let cat = NyanCat()
        cat.setScale(GameScene.scale)
        let nyanY = random(min: self.size.height * 0.33, max: self.size.height * 0.8)
        let from = CGPoint(x: -cat.size.width, y: nyanY)
        let to = CGPoint(x: self.size.width + cat.size.width, y: nyanY)
        cat.position = from
        cat.zPosition = self.gameZPosition(zPosition: 2)
        
        self.addChild(cat)
        cat.nyanNyanNyan(from: from, to: to) {
            self.startNyaning()
        }
        
    }
    
    func startNyaning() {
        let waitTime = self.random(min: 10.0, max: 50.0)
        let waitAction = SKAction.wait(forDuration: TimeInterval(waitTime))
        let spawnAction = SKAction.run {
            self.spawnNyanCat()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run(sequence)
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
