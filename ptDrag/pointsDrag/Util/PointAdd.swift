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



extension CGPoint{
    mutating
    func scale(by rate: CGFloat, forS size: CGSize){
        let newX = size.width * 0.5 * rate + (x - size.width * 0.5) * rate * 0.5
        let newY = size.height * 0.5 * rate + (y - size.height * 0.5) * rate * 0.5
        self = CGPoint(x: newX, y: newY)
    }
}
