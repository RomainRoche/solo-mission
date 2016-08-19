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
    private(set) var heatLimit: Int = 5
    
    // - the current heat, when set calls a block
    private(set) var heat: Int = 0
    
    // - an accessor to the overheat ratio
    var overheatRatio: Float {
        get {
            return Float(heat)/Float(heatLimit)
        }
    }
    
    // - can set an infinite shoot 
    var infiniteShoot: Bool = false
    
    // - a timer to decrease heat
    private var coolOffTimer: Timer?
    private let coolOffTimerStepInterval: TimeInterval = 0.5
    private var isFirstCoolOffCallback: Bool = false
    
    // - block called when cool of starts
    var startsToCoolOff:((TimeInterval) -> Void)?
    
    // MARK: private
    
    @objc private func coolOffCallback(_ timer: Timer) {
        
        // call the block if needed
        if isFirstCoolOffCallback {
            
            isFirstCoolOffCallback = false
            
            if startsToCoolOff != nil {
                let time: TimeInterval = coolOffTimerStepInterval * TimeInterval(heat)
                startsToCoolOff!(time)
            }
            
            coolOffTimer = Timer.scheduledTimer(timeInterval: coolOffTimerStepInterval,
                                                target: self,
                                                selector: #selector(SpaceShipLaserOverheat.coolOffCallback(_:)),
                                                userInfo: nil,
                                                repeats: true)
            
        }
        
        // decrease the heat
        self.heat = max(heat - 1, 0)
        
        // if heat reaches 0 stop decreasing
        if self.heat == 0 {
            timer.invalidate()
        }
        
    }
    
    // MARK: public
    
    func canShoot() -> Bool {
        return heat < heatLimit || infiniteShoot
    }
    
    func didShot() {

        self.heat = min(heat + 1, heatLimit)
        
        coolOffTimer?.invalidate()
        isFirstCoolOffCallback = true
        coolOffTimer = Timer.scheduledTimer(timeInterval: coolOffTimerStepInterval * 2,
                                       target: self,
                                       selector: #selector(SpaceShipLaserOverheat.coolOffCallback(_:)),
                                       userInfo: nil,
                                       repeats: false)
        
    }
    
    func upgrade(heatLimitIncrease i: Int) {
        heatLimit += i
    }
    
}
