//
//  SpaceNode.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 23/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpaceNode: SKSpriteNode {

    let spaceTexture: SKTexture = SKTexture(image: #imageLiteral(resourceName: "background"))
    let spaceSpeed: TimeInterval = 5.0
    let starsSpeed: TimeInterval = 350.0 // 350 px per seconds
    
    var tile0: SKSpriteNode
    var tile1: SKSpriteNode
    var tile2: SKSpriteNode
    
    // MARK: public
    
    init() {
        
        tile0 = SKSpriteNode(texture: spaceTexture)
        tile1 = SKSpriteNode(texture: spaceTexture)
        tile2 = SKSpriteNode(texture: spaceTexture)
        
        super.init(texture: nil, color: UIColor.black(), size: spaceTexture.size())
        
        tile0.position = CGPoint(x: 0.0, y: 0.0)
        tile1.position = CGPoint(x: 0.0, y: self.spaceTexture.size().height)
        tile2.position = CGPoint(x: 0.0, y: self.spaceTexture.size().height * 2.0)
        
        self.addChild(tile0)
        self.addChild(tile1)
        self.addChild(tile2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaT: TimeInterval) {
        
        let distance = deltaT * starsSpeed
        tile0.position.y -= CGFloat(distance)
        tile1.position.y -= CGFloat(distance)
        tile2.position.y -= CGFloat(distance)

        if tile0.position.y < -(self.spaceTexture.size().height + 100) {
            tile0.removeFromParent()
            tile0 = tile1
            tile1 = tile2
            tile2 = SKSpriteNode(texture: spaceTexture)
            tile2.position = CGPoint(x: 0.0, y: tile1.position.y + tile1.size.height)
            self.addChild(tile2)
        }
        
    }
    
}
