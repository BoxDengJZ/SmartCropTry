//
//  ButtomVIewP.swift
//  petit
//
//  Created by Jz D on 2021/2/3.
//  Copyright © 2021 swift. All rights reserved.
//

import UIKit

class ButtomViewP: UIView{
    

    lazy var dismissBtn: UIButton = {
        let edge: CGFloat = 45
        let b = UIButton(frame: CGRect(x: 40, y: 58, width: edge, height: edge))
        b.setImage(UIImage(named: "fork_4_kWa"), for: .normal)
        b.adjustsImageWhenHighlighted = false
        return b
    }()

    
    lazy var albumBu: UIButton = {
        let edge: CGFloat = 45
        let x = UI.std.width - 40 - edge
        let b = UIButton(frame: CGRect(x: x, y: 58, width: edge, height: edge))
        b.setImage(UIImage(named: "album_4_kiWa"), for: .normal)
        
        b.adjustsImageWhenHighlighted = false
        return b
    }()
    
    
    
    lazy var largeCircleB: UIImageView = {
        let img = UIImageView(image: UIImage(named: "camera_4_highWox"))
        img.isUserInteractionEnabled = true
        return img
    }()
    
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.black
        addSubs([largeCircleB,
                 dismissBtn, albumBu])
    
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let largeCircleH: CGFloat = 60
        largeCircleB.frame = CGRect(x: (bounds.width-largeCircleH)/2, y: 48, width: largeCircleH, height: largeCircleH)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
