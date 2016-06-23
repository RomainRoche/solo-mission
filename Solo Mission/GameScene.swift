//
//  GameScene.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 23/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound: SKAction = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    let scale: CGFloat = 1.0 / UIScreen.main().scale
//    let gameArea: CGRect
//    
//    override init(size: CGSize) {
//        let maxAspectRatio: CGFloat =
//        super.init(size: size)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func didMove(to view: SKView) {
        
        print("view size is \(view.bounds.size)")
        print("scene size is \(self.size)")
        
        let background: SKSpriteNode = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)

    }
    
    func fireBullet() {
        
        // create a bullet
        let bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch: CGPoint = touch.location(in: self)
            let previous:CGPoint = touch.previousLocation(in: self)
            let amountDragged: CGFloat = pointOfTouch.x - previous.x
            
            print("position x is \(player.position.x)")
            var x: CGFloat = player.position.x + amountDragged
            x = max(player.size.width / 2, x)
            x = min(self.size.width - player.size.width / 2, x)
            player.position.x = x
            
        }
        
    }
    
}
