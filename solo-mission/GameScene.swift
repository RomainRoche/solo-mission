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
    static let NyanCat: UInt32 = 0b1000 // 8
}

enum GameState {
    case none
    case waiting
    case inGame
    case gameOver
}

extension SKAction {
    class func setSpaceSpeed(to speed: TimeInterval, duration: TimeInterval) -> SKAction {
        
        var initialSpeed: TimeInterval? = nil
        var deltaSpeed: TimeInterval? = nil
        
        return SKAction.customAction(withDuration: duration) {
            node, elapsedTime in
            
            // if this is applied to a GameScene
            if let space = node as? GameScene {
            
                // only on the very first loop, since after starsSpeed is 
                // modified
                if initialSpeed == nil {
                    initialSpeed = space.starsSpeed
                    deltaSpeed = speed - initialSpeed!
                }
                
                // apply the fraction
                let fraction = (duration != 0.0 ? Float(elapsedTime / CGFloat(duration)) : 1.0)
                space.starsSpeed = initialSpeed! + (deltaSpeed! * TimeInterval(fraction))
        
            }
            
        }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static let scale: CGFloat = 1.0 - (1.0 / UIScreen.main().scale)
    static let backgroundNodeName = "background-node"
    static let planetNodeName = "planet-node"
    
    // handles the stars and the background
    
    private let spaceTexture: SKTexture = SKTexture(image: #imageLiteral(resourceName: "background"))
    var starsSpeed: TimeInterval = 120.0 // px per seconds
    private let limitY: CGFloat
    private var tilesCount: Int = 0
    
    // game data
    
    private var startPanel: StartPanelNode? = nil
    private var gameState: GameState = .none {
        didSet {
            switch gameState {
            case .waiting:
                self.setWaitingGameState()
                break
            case .inGame:
                self.setInGameState()
                break
            case .gameOver:
                self.setGameOverState()
                break
            default: break
            }
        }
        
    }
    
    private let scoreLabel: SKLabelNode?
    private var score: Int = 0 {
        didSet {
            scoreLabel?.text = self.scoreText()
            let scale = SKAction.scale(to: 1.2, duration: 0.06)
            let unscale = SKAction.scale(to: 1.0, duration: 0.06)
            scoreLabel?.run(SKAction.sequence([scale, unscale]))
            if score % 3000 == 0 {
                enemiesSpeedMultiplier += 0.1
            } else if score % 1000 == 0 {
                spawnEnemiesInterval = max(0.5, spawnEnemiesInterval - 0.5)
                self.startSpawningEnemies(interval: spawnEnemiesInterval)
                self.setStarsSpeed(self.starsSpeed + 50.0, duration: 0.5)
            }
        }
    }
    
    private let livesLabel: SKLabelNode?
    private var lives: Int = 3 {
        didSet {
            livesLabel?.text = self.livesText()
            let scale = SKAction.scale(to: 1.2, duration: 0.06)
            let unscale = SKAction.scale(to: 1.0, duration: 0.06)
            livesLabel?.run(SKAction.sequence([scale, unscale]))
            if lives == 0 && !GodMode {
                self.gameState = .gameOver
            }
        }
    }
    
    private var spawnEnemiesInterval: TimeInterval = 4.0
    private var enemiesSpeedMultiplier: CGFloat = 1.0
    
    // update loop
    
    private var lastUpdate: TimeInterval = 0.0
    
    // player
    
    private let player: SpaceShip = SpaceShip()
    private let allowVerticalMove = true
    private let playerBaseY: CGFloat = 0.2
    private let playerMaxY: CGFloat = 0.25
    private let playerMinY: CGFloat = 0.15
    
    // MARK: - private
    
    private func scoreText() -> String {
        return "SCORE : \(score)"
    }
    
    private func livesText() -> String {
        return "LIVES : \(lives)"
    }
    
    private func backgroundZPosition(zPosition: CGFloat) -> CGFloat {
        return zPosition + CGFloat(tilesCount)
    }
    
    private func gameZPosition(zPosition: CGFloat) -> CGFloat {
        return zPosition + 30.0
    }
    
    private func scoreBoardZPosition(zPosition: CGFloat) -> CGFloat {
        return zPosition + 100.0
    }
    
    // MARK: - game state
    
    private func setWaitingGameState() {
        
        startPanel?.removeFromParent()
        startPanel = StartPanelNode(size: self.size)
        startPanel?.zPosition = self.scoreBoardZPosition(zPosition: 2)
        self.addChild(startPanel!)
        
        self.setStarsSpeed(120.0, duration: 0.5)
        
        player.position = CGPoint(x: self.size.width/2, y: -player.size.height)
        self.addChild(player)
        
    }
    
    private func setInGameState() {
        
        self.score = 0
        self.lives = 3
        spawnEnemiesInterval = 4.0
        enemiesSpeedMultiplier = 1.0
        
        self.setStarsSpeed(550.0, duration: 0.5)
        
        startPanel?.removeFromParent()
        startPanel = nil
        
        // player appear
        let playerAppear = SKAction.moveTo(y: self.size.height * self.playerBaseY, duration: 0.3)
        self.player.run(playerAppear)
        
        // pop enemies
        self.startSpawningEnemies(interval: self.spawnEnemiesInterval)
        
        // planets
        self.startSpawningPlanets()
        
        // nyan nyan nyan
        self.startSpawningNyanCat()
        
    }
    
    private func setGameOverState() {
        
        self.stopSpawningEnemies()
        self.stopSpawningPlanets()
        self.stopSpawningNyanCat()
        
        player.removeFromParent()
        
        self.setWaitingGameState()
        
    }
    
    // MARK: - physics
    
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
                    self.gameState = .gameOver
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
                self.score += 100
            }
            // ... and bullet disappear
            body1.node?.removeFromParent()
        }
        
        // bullet hits nyan cat
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.NyanCat {
            if let node = body2.node {
                // otherwise enemy explodes ...
                self.nodeExplode(node)
                self.lives += 1
            }
            // ... and bullet disappear
            body1.node?.removeFromParent()
        }
        
    }
    
    // MARK: - implementation
    
    override init(size: CGSize) {
        
        // scroll indexes
        let centerY = (size.height - spaceTexture.size().height) / 2
        limitY = 0.0 - centerY - spaceTexture.size().height
        
        // label
        scoreLabel = SKLabelNode()
        scoreLabel?.fontSize = 65.0
        scoreLabel?.fontName = "DINCondensed-Bold"
        scoreLabel?.horizontalAlignmentMode = .left
        scoreLabel?.verticalAlignmentMode = .top
        
        livesLabel = SKLabelNode()
        livesLabel?.fontSize = 65.0
        livesLabel?.fontName = "DINCondensed-Bold"
        livesLabel?.horizontalAlignmentMode = .right
        livesLabel?.verticalAlignmentMode = .top
        
        // super
        super.init(size: size)
        
        // prepare player
        player.setScale(GameScene.scale)
        player.zPosition = self.gameZPosition(zPosition: 4)
        
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
            tile.name = GameScene.backgroundNodeName
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
        
        // score and lives label prep work
        
        scoreLabel?.zPosition = self.scoreBoardZPosition(zPosition: 1)
        scoreLabel?.position = CGPoint(x: 22.0, y: self.size.height - 22.0)
        scoreLabel?.text = self.scoreText()
        self.addChild(scoreLabel!)
        
        livesLabel?.zPosition = self.scoreBoardZPosition(zPosition: 1.1)
        livesLabel?.position = CGPoint(x: self.size.width - 22.0, y: self.size.height - 22.0)
        livesLabel?.text = self.livesText()
        self.addChild(livesLabel!)
        
        self.gameState = .waiting
        
        if GodMode {
            player.physicsBody?.categoryBitMask = PhysicsCategories.None
        }

    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate != 0 {
            
            let deltaT = currentTime - lastUpdate
            var distance = deltaT * starsSpeed
            var zPos = 0
            
            // move background
            self.enumerateChildNodes(withName: GameScene.backgroundNodeName) { background, stop in
                background.position.y -= CGFloat(distance)
                background.zPosition = CGFloat(zPos)
                zPos += 1
                if background.position.y < self.limitY {
                    background.position.y += CGFloat(self.tilesCount) * self.spaceTexture.size().height
                }
            }
            
            // move planet
            distance = deltaT * (starsSpeed * 1.1)
            self.enumerateChildNodes(withName: GameScene.planetNodeName) { node, stop in
                node.position.y -= CGFloat(distance)
                if let planet = node as? SKSpriteNode {
                    if planet.position.y < -(self.size.height * 0.5 + planet.size.height) {
                        node.removeFromParent()
                    }
                }
            }
            
        }
        lastUpdate = currentTime
    }
    
    func setStarsSpeed(_ speed: TimeInterval, duration: TimeInterval) {
        let action = SKAction.setSpaceSpeed(to: speed, duration: duration)
        action.timingMode = SKActionTimingMode.easeInEaseOut
        self.run(action)
    }
    
    // MARK: - shooting management
    
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
        self.addChild(player.fireBullet(destinationY: self.size.height))
    }
    
    // MARK: - spawn objects
    
    // spawn planet //
    
    static let spawnPlanetsAction = "spawn-planets"
    
    func spawnPlanet() {
        
        let textureIndex = arc4random() % 5
        let texture = SKTexture(imageNamed: "planet\(textureIndex)")
        let planet = SKSpriteNode(texture: texture, color: UIColor.clear(), size: texture.size())
        planet.name = GameScene.planetNodeName
        planet.setScale(random(min: 1.0, max: 3.0))
        
        let randomY = random(min: 600.0, max: 2500.0)
        planet.position.y = self.size.height + randomY
        planet.position.x = random(min: 10.0, max: self.size.width - 10.0)
        
        planet.zPosition = backgroundZPosition(zPosition: 1)
        self.addChild(planet)
        
        self.startSpawningPlanets()
        
    }
    
    func startSpawningPlanets() {
        let waitTime = random(min: 10.0, max: 40.0)
        let waitAction = SKAction.wait(forDuration: TimeInterval(waitTime))
        let spawnAction = SKAction.run {
            self.spawnPlanet()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run(sequence, withKey: GameScene.spawnPlanetsAction)
    }
    
    func stopSpawningPlanets() {
        self.removeAction(forKey: GameScene.spawnPlanetsAction)
    }
    
    // spawn enemies //
    
    static let spawnEnemiesAction = "spawn-enemies"
    
    func spawnEnemy() {
        
        let enemy = EnemyNode()
        enemy.setScale(GameScene.scale)
        var moveType = EnemyShipMove.Straight
        if score > 4000 {
            moveType = (arc4random() % 2 == 0 ? .Straight : .Curvy)
        }
        enemy.move = moveType
        enemy.zPosition = self.gameZPosition(zPosition: 5)
        enemy.speed = enemy.speed * enemiesSpeedMultiplier
        self.addChild(enemy)
        
        let randomXStart = random(min: 10.0, max: self.size.width - 10.0)
        let yStart = self.size.height + 200.0
        
        let randomXEnd = random(min: 10.0, max: self.size.width - 10.0)
        let yEnd: CGFloat = -enemy.size.height
        
        enemy.move(from: CGPoint(x: randomXStart, y: yStart), to: CGPoint(x: randomXEnd, y: yEnd)) {
            self.lives = self.lives - 1
        }
        
    }
    
    func startSpawningEnemies(interval: TimeInterval) {
        self.removeAction(forKey: GameScene.spawnEnemiesAction)
        let waitAction = SKAction.wait(forDuration: interval)
        let spawnAction = SKAction.run {
            self.spawnEnemy()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run( SKAction.repeatForever(sequence), withKey: GameScene.spawnEnemiesAction)
    }
    
    func stopSpawningEnemies() {
        self.removeAction(forKey: GameScene.spawnEnemiesAction)
    }
    
    // spawn nyan cat //
    
    static let spawnNyanCatAction = "spawn-nyan-cat"
    
    func spawnNyanCat() {
        
        let cat = NyanCat()
        cat.setScale(GameScene.scale)
        let nyanY = random(min: self.size.height * 0.33, max: self.size.height * 0.8)
        let from = CGPoint(x: -cat.size.width, y: nyanY)
        let to = CGPoint(x: self.size.width + cat.size.width, y: nyanY)
        cat.position = from
        cat.zPosition = self.gameZPosition(zPosition: 2)
        
        self.addChild(cat)
        cat.nyanNyanNyan(from: from, to: to)
        self.startSpawningNyanCat()
        
    }
    
    func startSpawningNyanCat() {
        let waitTime = random(min: 50.0, max: 120.0)
        let waitAction = SKAction.wait(forDuration: TimeInterval(waitTime))
        let spawnAction = SKAction.run {
            self.spawnNyanCat()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run(sequence, withKey: GameScene.spawnNyanCatAction)
    }
    
    func stopSpawningNyanCat() {
        self.removeAction(forKey: GameScene.spawnNyanCatAction)
    }
    
    // MARK: - handle touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameState == .waiting || gameState == .gameOver {
            self.gameState = .inGame
            return
        }
        
        if gameState == .inGame {
            fireBullet()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameState != .inGame {
            return
        }
        
        var i = 0
        for touch: AnyObject in touches {
            
            // allow 2 touches to move, can make the ship move faster
            if i >= 2 {
                break
            }
            
            let pointOfTouch = touch.location(in: self)
            let previous = touch.previousLocation(in: self)
            let amountDraggedX = pointOfTouch.x - previous.x
            let amountDraggedY = pointOfTouch.y - previous.y
            
            var x = player.position.x + amountDraggedX
            x = max(player.size.width / 2, x)
            x = min(self.size.width - player.size.width / 2, x)
            
            var y = player.position.y
            if allowVerticalMove {
                y += amountDraggedY
                y = max(self.size.height * playerMinY, y)
                y = min(self.size.height * playerMaxY, y)
                if i == 0 {
                    player.accelerate(accelerate: amountDraggedY)
                }
            }
            
            player.position = CGPoint(x: x, y: y)
            
            i += 1
            
        }
        
    }
    
}
