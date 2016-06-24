//
//  EnemyNode.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 24/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

class EnemyNode: SKSpriteNode {
    
    init() {
        let texture = SKTexture(image: #imageLiteral(resourceName: "enemyShip"))
        let size = CGSize(width: 88, height: 204)
        super.init(texture: texture, color: UIColor.clear(), size: size)
        self.zPosition = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(from: CGPoint, to: CGPoint) {
        
        // set position
        self.position = from
        
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        let distance = sqrt((deltaX*deltaX + deltaY*deltaY))
        let duration = distance / 850.0 // (speed is 850px per second)
        
        // move
        let moveAction = SKAction.move(to: to, duration: TimeInterval(duration))
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        self.run(sequence)
        
        // rotate depending on the angle
        let angle =  atan(deltaX/deltaY)
        self.zRotation = -angle
        
    }
    
}
