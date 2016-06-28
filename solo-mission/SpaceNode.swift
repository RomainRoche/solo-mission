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
    var tileToCheck: SKSpriteNode
    
    // MARK: public
    
    init(size: CGSize) {
        
        tile0 = SKSpriteNode(texture: spaceTexture)
        tile1 = SKSpriteNode(texture: spaceTexture)
        tile2 = SKSpriteNode(texture: spaceTexture)
        tileToCheck = tile0
        
        //KEEP FOR DEBUG
//        tile0 = SKSpriteNode(color: UIColor.red().withAlphaComponent(0.6), size: spaceTexture.size())
//        tile1 = SKSpriteNode(color: UIColor.green().withAlphaComponent(0.6), size: spaceTexture.size())
//        tile2 = SKSpriteNode(color: UIColor.blue().withAlphaComponent(0.6), size: spaceTexture.size())
        
        super.init(texture: nil, color: UIColor.white(), size: size)
        
        var y = -((self.size.height - tile0.size.height) / 2)
        tile0.position = CGPoint(x: 0.0, y: y)
        y += self.spaceTexture.size().height
        tile1.position = CGPoint(x: 0.0, y: y)
        y += self.spaceTexture.size().height
        tile2.position = CGPoint(x: 0.0, y: y)
        
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

        let limitY = -((self.size.height - tile0.size.height) / 2)
        if tile1.position.y < limitY {
            self.tile0.position.y = self.tile2.position.y + self.tile2.size.height
            let tmp = self.tile0
            self.tile0 = self.tile1
            self.tile1 = self.tile2
            self.tile2 = tmp
        }
        
    }
    
}
