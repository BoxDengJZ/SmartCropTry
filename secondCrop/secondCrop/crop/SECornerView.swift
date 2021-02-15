//
//  CornerView.swift
//  CropViewController
//
//  Created by Никита Разумный on 11/5/17.
//  Copyright © 2017 resquare. All rights reserved.
//

import UIKit

class SECornerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width / 2.0
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func scaleUp() {
        UIView.animate(withDuration: 0.15, animations: {
            self.layer.borderWidth = 0.5
            self.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
        }) { (_) in
            self.setNeedsDisplay()
        }
    }
    
    func scaleDown() {
        UIView.animate(withDuration: 0.15, animations: {
            self.layer.borderWidth = 1
            self.transform = CGAffineTransform.identity
        }) { (_) in
            self.setNeedsDisplay()
        }
    }
}
