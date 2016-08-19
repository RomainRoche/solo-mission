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
    private(set) var heatLimit: Int = 10
    private let coolOffTime: TimeInterval = 1.2
    
    // - the current heat, when set calls a block
    private(set) var heat: Int = 0 {
        willSet {
            if heatWillChange != nil {
                let deltaHeatRatio = Float(abs(heat - newValue)) / Float(heatLimit)
                let timeRatio = TimeInterval(coolOffTime * TimeInterval(deltaHeatRatio))
                heatWillChange!(newValue, timeRatio)
            }
        }
//        didSet {
//            if heatDidChange != nil {
//                heatDidChange!(heat)
//            }
//        }
    }
    
    // - the block called when heat changes
    var heatWillChange:((Int, TimeInterval) -> Void)?
    var heatDidChange: ((Int) -> Void)?
    
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
        self.heat = 0
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
                                       repeats: false)
        
    }
    
    func upgrade(heatLimitIncrease i: Int) {
        heatLimit += i
    }
    
}
