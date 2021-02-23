//
//  LinedTipView.swift
//  petit
//
//  Created by Jz D on 2021/2/3.
//  Copyright © 2021 swift. All rights reserved.
//

import UIKit

class LinedTipView: UIView {

    
    lazy var tipIcon: UIImageView = {
        let frm = CGRect(x: 0, y: 0, width: 160, height: 160)
        let bel = UIImageView(frame: frm)
        bel.image = UIImage(named: "camera_4_tip")
        
        return bel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubs([ tipIcon ])
      //  layer.debug()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tipIcon.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let b = UIBezierPath()
        b.lineWidth = 1
        let pieceX = rect.width * 0.33
        let pieceY = rect.height * 0.33
        // 两竖
        b.move(to: CGPoint(x: pieceX, y: 0))
        b.addLine(to: CGPoint(x: pieceX, y: rect.height))
        
        b.move(to: CGPoint(x: pieceX * 2, y: 0))
        b.addLine(to: CGPoint(x: pieceX * 2, y: rect.height))
        
        // 两横
        b.move(to: CGPoint(x: 0, y: pieceY))
        b.addLine(to: CGPoint(x: rect.width, y: pieceY))
        
        b.move(to: CGPoint(x: 0, y: pieceY * 2))
        b.addLine(to: CGPoint(x: rect.width, y: pieceY * 2))
        
        UIColor(rgb: 0xFFFFFF, alpha: 0.6).setStroke()
        b.stroke()
    }
    

}






extension UIColor {
    
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    
    
    convenience init(rgb: Int, alpha: CGFloat = 1) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}
