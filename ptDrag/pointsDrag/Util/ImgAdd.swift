//
//  ImgAdd.swift
//  pointsDrag
//
//  Created by Jz D on 2020/10/10.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit




extension UIImage{
    
    
    func image(rotated time: Int) -> UIImage{
        guard time != 0 else {
            return self
        }
        
        let radian = CGFloat(time) * CGFloat.pi / 2
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radian))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radian)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self

    }
    
    
    
}



extension UIImage {
    var leftTurn: UIImage{
        image(rotated: 1)
    }
}

