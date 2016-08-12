//
//  SpaceShipLaserOverheat.swift
//  solo-mission
//
//  Created by Romain ROCHE on 10/08/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import Foundation

class SpaceShipLaserOverheat {
    
    // MARK: variables for overheat
    
    // - heat limit, the max number of shot the laser can shot
    private var heatLimit: Int = 10
    
    // - the current heat, when set calls a block
    private(set) var heat: Int = 0 {
        didSet {
            if heatDidChange != nil {
                heatDidChange!(heat: heat)
            }
        }
    }
    
    // - the block called when heat changes
    var heatDidChange: ((heat: Int) -> Void)?
    
    // - an accessor to the overheat ratio
    var overheatRatio: Float {
        get {
            return Float(heat)/Float(heatLimit)
        }
    }
    
    // - can set an infinite shoot 
    var infiniteShoot: Bool = false
    
    // - a timer to decrease heat
    private var coolOff: Timer?
    
    // MARK: private
    
    @objc private func coolOffCallback(_ timer: Timer) {
        self.heat = max(self.heat - 1, 0)
        if (self.heat == 0) {
            self.coolOff?.invalidate()
        }
    }
    
    // MARK: public
    
    func canShoot() -> Bool {
        return heat < heatLimit || infiniteShoot
    }
    
    func didShot() {

        self.heat = min(heat + 1, heatLimit)
        
        coolOff?.invalidate()
        coolOff = Timer.scheduledTimer(timeInterval: 0.5,
                                       target: self,
                                       selector: #selector(SpaceShipLaserOverheat.coolOffCallback(_:)),
                                       userInfo: nil,
                                       repeats: true)
        
    }
    
    func upgrade(heatLimitIncrease i: Int) {
        heatLimit += i
    }
    
}
