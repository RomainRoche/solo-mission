//
//  NyanCat.swift
//  solo-mission
//
//  Created by Romain ROCHE on 27/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

class NyanCat: SKSpriteNode {

    var textures: [SKTexture]
    let playNyan: SKAction = SKAction.playSoundFileNamed("nyan-short.wav", waitForCompletion: false)
    
    init() {
        
        let nyan = SKTexture(image: #imageLiteral(resourceName: "nyan0"))
        textures = [SKTexture]()
        for i in 0...11 {
            let texture = SKTexture(imageNamed: "nyan\(i)")
            textures.append(texture)
        }
        
        super.init(texture: nyan, color: UIColor.clear(), size: nyan.size())

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func nyanNyanNyan(from: CGPoint, to: CGPoint) {
        
        self.position = from;
        
        let duration: TimeInterval = 3.0
        
        let move = SKAction.move(to: to, duration: duration)
        
        let timePerFrame: TimeInterval = 0.05
        let loopTime = timePerFrame * TimeInterval(textures.count)
        let loopCount = duration / loopTime
        
        let nyan = SKAction.animate(with: textures, timePerFrame: timePerFrame, resize: false, restore: false)
        let nyanLoop = SKAction.repeat(nyan, count: Int(loopCount + 2))
        let group = SKAction.group([move, nyanLoop])
        
        let delete = SKAction.removeFromParent()
        
        self.run(SKAction.sequence([playNyan, group, delete]))
        
    }
    
}
