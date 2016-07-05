//
//  Utils.swift
//  solo-mission
//
//  Created by Romain ROCHE on 04/07/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import Foundation
import CoreGraphics

let GodMode: Bool = false

struct PhysicsCategories {
    static let None:    UInt32 = 0      // 0
    static let Player:  UInt32 = 0b1    // 1
    static let Bullet:  UInt32 = 0b10   // 2
    static let Enemy:   UInt32 = 0b100  // 4
    static let NyanCat: UInt32 = 0b1000 // 8
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}
