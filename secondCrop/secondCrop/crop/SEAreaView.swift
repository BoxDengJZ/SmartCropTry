//
//  AreaView.swift
//  CropViewController
//
//  Created by Никита Разумный on 11/5/17.
//  Copyright © 2017 resquare. All rights reserved.
//

import UIKit

class SEAreaView: UIView {

    var path: CGMutablePath?
    var isPathValid = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let p = path else { return }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(true)
        context?.clip(to: rect)

        context?.addPath(p)
        context?.setLineWidth(1)
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        
        
        context?.setStrokeColor((isPathValid ? Setting.std.goodAreaColor : Setting.std.badAreaColor).cgColor)
        context?.strokePath()
        context?.addRect(bounds)
        context?.addPath(p)
        
        context?.setFillColor(UIColor(white: 0.3, alpha: 0.2).cgColor)
        context?.drawPath(using: .eoFill)
    }
    
    
    func fill(path p: CGMutablePath){
        path = p
        setNeedsDisplay()
    }
}
