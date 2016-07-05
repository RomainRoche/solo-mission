//
//  SKNodeExplosion.swift
//  solo-mission
//
//  Created by Romain ROCHE on 05/07/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    func explode(removeFromParent: Bool = true, completion: (()->Void) = {}) {
        
        let boom = SKSpriteNode(imageNamed: "explosion")
        boom.setScale(0.0)
        boom.zPosition = self.zPosition + 0.1
        boom.position = self.position
        self.scene?.addChild(boom)
        
        if removeFromParent {
            self.removeFromParent()
        } else {
            self.isHidden = true
        }
        
        let boomAppear = SKAction.scale(to: GameScene.scale, duration: 0.2)
        let boomFade = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let boomAction = SKAction.group([boomAppear, boomFade])
        let removeBoom = SKAction.removeFromParent()
        
        boom.run(SKAction.sequence([boomAction, removeBoom])) {
            completion()
        }
        
    }
    
}
