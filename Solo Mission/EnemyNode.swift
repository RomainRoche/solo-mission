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
        
        self.position = from
        
        let moveAction: SKAction = SKAction.move(to: to, duration: 5.0)
        let removeAction: SKAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        self.run(sequence)
        
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        let angle =  atan(deltaX/deltaY)
        self.zRotation = -angle
        print("\ndelta x: \(deltaX)\ndeltaY: \(deltaY)\nangle: \(angle)")
    }
    
}
