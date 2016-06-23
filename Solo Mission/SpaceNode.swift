//
//  SpaceNode.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 23/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpaceNode: SKNode {

    init() {
        let texture: SKTexture = SKTexture(image: #imageLiteral(resourceName: "background"))
        super.init(texture: texture, color: UIColor.clear(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveInSpace() {
        self.addChild(<#T##node: SKNode##SKNode#>)
    }
    
}
