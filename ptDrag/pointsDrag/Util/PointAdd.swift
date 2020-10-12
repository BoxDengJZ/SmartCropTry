//
//  PointAdd.swift
//  pointsDrag
//
//  Created by Jz D on 2020/10/12.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit





func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

