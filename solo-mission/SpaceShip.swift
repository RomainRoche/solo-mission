//
//  SpaceShip.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 24/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpaceShip: SKSpriteNode {

    let bulletSound: SKAction = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    
    init() {
        let texture = SKTexture(image: #imageLiteral(resourceName: "playerShip"))
        let size = CGSize(width: 88, height: 204)
        super.init(texture: texture, color: UIColor.clear(), size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fireBullet(destinationY: CGFloat) -> SKSpriteNode {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: 25, height: 100)
        bullet.setScale(GameScene.scale)
        bullet.position = self.position
        bullet.zPosition = self.zPosition - 1
        bullet.alpha = 0.0
        
        // two actions
        let moveBullet = SKAction.moveTo(y: destinationY + bullet.size.height, duration: 1)
        let appearBullet = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        let bulletAnimation = SKAction.group([moveBullet, appearBullet])
        let deleteBullet = SKAction.removeFromParent()
        
        // sequence of actions
        let bulletSequence = SKAction.sequence([bulletSound, bulletAnimation, deleteBullet])
        bullet.run(bulletSequence)
        
        return bullet
        
    }
    
}
