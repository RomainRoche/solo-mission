//
//  SpaceShipLaserOverheat.swift
//  solo-mission
//
//  Created by Romain ROCHE on 10/08/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import Foundation

class SpaceShipLaserOverheat {
    
    private var heatLimit: Int = 10
    private(set) var heat: Int = 0 {
        didSet {
            if heatDidChange != nil {
                heatDidChange!(heat: heat)
            }
        }
    }
    var heatDidChange: ((heat: Int) -> Void)?
    
    private var coolOff: Timer?
    
    @objc private func coolOffCallback(_ timer: Timer) {
        self.heat = max(self.heat - 1, 0)
        if (self.heat == 0) {
            self.coolOff?.invalidate()
        }
    }
    
    func canShoot() -> Bool {
        return heat < heatLimit
    }
    
    func didShot() {

        self.heat = min(heat + 1, heatLimit)
        
        coolOff?.invalidate()
        coolOff = Timer.scheduledTimer(timeInterval: 0.1,
                                       target: self,
                                       selector: #selector(SpaceShipLaserOverheat.coolOffCallback(_:)),
                                       userInfo: nil,
                                       repeats: true)
        
    }
    
    func upgrade(heatLimitIncrease i: Int) {
        heatLimit += i
    }
    
}
