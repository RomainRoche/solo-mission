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
        
        // particle emitter
        if let path = Bundle.main().pathForResource("MyParticle", ofType: "sks") {
            let rainbow = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            rainbow.position = CGPoint(x: -((self.size.width / 2) - 10), y: 0.0)
            rainbow.physicsBody = SKPhysicsBody()
            rainbow.physicsBody?.affectedByGravity = false
            rainbow.targetNode = self
            rainbow.zPosition = self.zPosition - 1
            self.addChild(rainbow)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func nyanNyanNyan(from: CGPoint, to: CGPoint) {
        
        let realTo = CGPoint(x: to.x + 300, y: to.y)
        self.position = from;
        
        let duration: TimeInterval = 3.0
        
        let move = SKAction.move(to: realTo, duration: duration)
        
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
