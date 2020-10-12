//
//  MagnifierView.swift
//  MagnifierView_demo
//
//  Created by lidongxi on 2018/3/23.
//  Copyright © 2018年 lidongxi. All rights reserved.
//

import UIKit

 class MagnifierView: UIView {

    
    public var renderView: UIView?
    
    public var renderPoint : CGPoint  = CGPoint.zero {
        didSet{
            self.layer.setNeedsDisplay()
        }
    }
    
    override var isHidden: Bool {
        didSet{
            layer.borderColor = isHidden ? UIColor.clear.cgColor : UIColor.lightGray.cgColor
        }
    }
 

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        isHidden = true
        layer.delegate = self
        // 保证和屏幕读取像素的比例一致
        layer.contentsScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        guard let renderer = renderView else {
            return
        }
        // 提前位移半个长宽的坑
        ctx.translateBy(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
        /// 缩放比例
        let scale : CGFloat = 3
        ctx.scaleBy(x: scale, y: scale)
        // 再次位移后就可以把触摸点移至self.center的位置
        ctx.translateBy(x: -renderPoint.x, y: -renderPoint.y)
        
        renderer.layer.render(in: ctx)
    }
    
}
