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
    let scoreLabel: SKLabelNode = SKLabelNode()
    
    init(size: CGSize) {
        
        let highScore = UserDefaults.standard().integer(forKey: HighScoreKey)
        
        scoreLabel.fontSize = 52.0
        scoreLabel.fontName = FontName
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.text = "HIGH SCORE : \(highScore)"
        
        label.fontSize = 80.0
        label.fontName = FontName
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = "TAP TO START"
        
        var pos = CGPoint(x: size.width / 2, y: size.height * 0.66)
        scoreLabel.position = pos
        pos.y -= scoreLabel.frame.size.height + 16.0
        label.position = pos
        
        super.init(texture: nil, color: UIColor.clear(), size: size)
        
        self.addChild(scoreLabel)
        self.addChild(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
