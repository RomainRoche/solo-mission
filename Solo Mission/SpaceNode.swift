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
    
    var currentNode: SKSpriteNode
    var nextNode: SKSpriteNode
    
    init() {
        
        currentNode = SKSpriteNode(texture: spaceTexture)
        nextNode = SKSpriteNode(texture: spaceTexture)
        super.init(texture: nil, color: UIColor.black(), size: spaceTexture.size())
        
        currentNode.position = CGPoint(x: 0.0, y: 0.0)
        
        nextNode.position = CGPoint(x: 0.0, y: self.spaceTexture.size().height)
        
        self.addChild(currentNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveInSpace() {
        
        self.currentNode.addChild(self.nextNode)
        let moveCurrentAction = SKAction.moveTo(y: -self.spaceTexture.size().height, duration: spaceSpeed)
        let goBackAction = SKAction.moveTo(y: 0.0, duration: 0.0)
        let moveAll = SKAction.sequence([moveCurrentAction, goBackAction])
        
        self.currentNode.run(SKAction.repeatForever(moveAll))
        
    }
    
}
