//
//  SpaceShipLaserOverheatNode.swift
//  solo-mission
//
//  Created by Romain ROCHE on 12/08/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit

class SpaceShipLaserOverheatNode: SKSpriteNode {

    let crop: SKCropNode = SKCropNode()
    let mask: SKSpriteNode = SKSpriteNode(color: UIColor.blue, size: CGSize.zero)
    let sprite: SKSpriteNode = SKSpriteNode(imageNamed: "overheat")
    
    static private let MaskSizeActionName = "SpaceShipLaserOverheatNodeMaskSizeActionName"
    
    init() {
        
        super.init(texture: nil, color: UIColor.red.withAlphaComponent(0.25), size: sprite.size)
        
        self.anchorPoint = CGPoint.zero
        
        sprite.anchorPoint = CGPoint.zero
        sprite.position = CGPoint.zero
        
        crop.addChild(sprite)
        self.addChild(crop)
        
        mask.size = sprite.size
        mask.anchorPoint = CGPoint.zero
        crop.maskNode = mask
        
        self.setOverheatPercentage(percentage: 0.0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setOverheatPercentage(percentage: Float) {
        mask.removeAction(forKey: SpaceShipLaserOverheatNode.MaskSizeActionName)
        let maskSizeHeight = sprite.size.height * CGFloat(percentage)
        let maskAction = SKAction.resize(toHeight: maskSizeHeight , duration: 0.2)
        mask.run(maskAction, withKey: SpaceShipLaserOverheatNode.MaskSizeActionName)
    }
    
    func setOverheatPercentage(percentage: Float, time: TimeInterval) {
        mask.removeAction(forKey: SpaceShipLaserOverheatNode.MaskSizeActionName)
        let maskSizeHeight = sprite.size.height * CGFloat(percentage)
        let maskAction = SKAction.resize(toHeight: maskSizeHeight , duration: time)
        mask.run(maskAction, withKey: SpaceShipLaserOverheatNode.MaskSizeActionName)
    }
    
}
