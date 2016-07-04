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

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}
