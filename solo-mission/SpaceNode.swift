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
    let starsSpeed: TimeInterval = 350.0 // px per seconds
    let limitY: CGFloat
    var tilesCount: Int = 0
    
    // MARK: public
    
    init(size: CGSize) {
        
        let centerY = (size.height - spaceTexture.size().height) / 2
        limitY = 0.0 - centerY - spaceTexture.size().height
        super.init(texture: nil, color: UIColor.white(), size: size)
        
        var y = -centerY
        let loopCount = Int(ceil((self.size.height / spaceTexture.size().height)))
        for _ in 0...loopCount {
            print("adding tile")
            tilesCount += 1
            let tile = SKSpriteNode(texture: spaceTexture)
            tile.position.y = y
            tile.name = "background"
            self.addChild(tile)
            y += self.spaceTexture.size().height
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaT: TimeInterval) {
        
        let distance = deltaT * starsSpeed
        
        self.enumerateChildNodes(withName: "background") { background, stop in
            background.position.y -= CGFloat(distance)
            if background.position.y < self.limitY {
                background.position.y += CGFloat(self.tilesCount) * self.spaceTexture.size().height
            }
        }
        
    }
    
}
