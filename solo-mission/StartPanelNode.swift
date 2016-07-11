//
//  StartPanelNode.swift
//  solo-mission
//
//  Created by Romain ROCHE on 01/07/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit

class StartPanelNode: SKSpriteNode {

    let label: SKLabelNode = SKLabelNode()
    
    init(size: CGSize) {
        
        let highScore = UserDefaults.standard().integer(forKey: HighScoreKey)
        
        label.fontSize = 80.0
        label.fontName = FontName
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = "HIGH SCORE : \(highScore), TAP TO START"
        
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        
        super.init(texture: nil, color: UIColor.clear(), size: size)
        
        self.addChild(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
