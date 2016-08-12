//
//  SpaceShipLaserOverheatNode.swift
//  solo-mission
//
//  Created by Romain ROCHE on 12/08/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit

class SpaceShipLaserOverheatNode: SKCropNode {

    let mask: SKSpriteNode = SKSpriteNode(color: UIColor.blue, size: CGSize.zero)
    let sprite: SKSpriteNode = SKSpriteNode(imageNamed: "overheat")
    var size: CGSize {
        get {
            return sprite.size
        }
    }
    
    override init() {
        
        super.init()
        
        self.addChild(sprite)
        
        mask.size = sprite.size
        self.maskNode = mask
        
        self.setOverheatPercentage(percentage: 0.0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setOverheatPercentage(percentage: Float) {
        let maskSize = self.size
        let maskAction = SKAction.resize(toHeight: maskSize.height * CGFloat(percentage), duration: 0.2)
        mask.run(maskAction)
    }
    
}
