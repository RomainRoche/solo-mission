//
//  FadeSoundNode.swift
//  solo-mission
//
//  Created by Romain ROCHE on 29/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

extension SKAction {
    class func changePlayerVolue(endVolume: Float, duration: TimeInterval) -> SKAction {
        let action = SKAction.customAction(withDuration: duration) {
            node, elapsedTime in
            
            if let soundNode = node as? FadeSoundNode {
                let distance = endVolume - soundNode.player!.volume
                let fraction = Float(elapsedTime / CGFloat(duration))
                soundNode.player?.volume += (fraction * distance)
            }
            
        }
        return action
    }
}

class FadeSoundNode: SKNode {
    
    let player: AVAudioPlayer?
    var fadeInDuration: TimeInterval = 0.0
    var fadeOutDuration: TimeInterval = 0.0
    
    
    class func changeVolumeAction(endVolume: Float, duration: TimeInterval) -> SKAction {
        
        let action = SKAction.customAction(withDuration: duration) {
            node, elapsedTime in
            
            if let soundNode = node as? FadeSoundNode {
                let distance = endVolume - soundNode.player!.volume
                let fraction = Float(elapsedTime / CGFloat(duration))
                soundNode.player?.volume += (fraction * distance)
            }
            
        }
        
        return action
    }
    
    init(fileNamed: String) {
        if let path = Bundle.main().pathForResource("nyan", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
            } catch {
                player = AVAudioPlayer()
                print(error)
            }
        } else {
            player = AVAudioPlayer()
        }
        player?.prepareToPlay()
        player?.volume = 1.0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play(currentTime: TimeInterval, duration: TimeInterval, end: ()->() = {}) {
        
        let startAction = SKAction.run {
            self.player?.currentTime = currentTime
            self.player?.play()
            self.player?.volume = 0.0
        }
        let fadeInAction = SKAction.changePlayerVolue(endVolume: 0.5, duration: fadeInDuration)
        let waitAction = SKAction.wait(forDuration: duration - fadeInDuration - fadeOutDuration)
        let fadeOutAction = SKAction.changePlayerVolue(endVolume: 0.0, duration: fadeOutDuration)
        let endAction = SKAction.run {
            self.player?.stop()
            end()
        }
        
        let sequence = SKAction.sequence([startAction, fadeInAction, waitAction, fadeOutAction, endAction])
        self.run(sequence)
        
    }
    
}
