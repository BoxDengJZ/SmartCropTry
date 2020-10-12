//
//  DirectionRotateB.swift
//  pointsDrag
//
//  Created by Jz D on 2020/10/12.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit




enum RotateOpt{
    case lhs, rhs
}




class DirectionRotateB: UIButton {

    
       let imgSize = CGSize(width: 32, height: 32)
       let titleW: CGFloat = 36
       
       let spacing: CGFloat = 6
       
       
       init(opt kind: RotateOpt){
           
           super.init(frame: .zero)
           let img: UIImage?
           let title: String
           switch kind {
           case .lhs:
               title = "左转"
               
               img = UIImage(named: "single_lhs_rotate")
           case .rhs:
               title = "右转"
               
               img = UIImage(named: "single_rhs_rotate")
           }
           setImage(img, for: .normal)
           setTitle(title, for: .normal)
           setTitleColor(UIColor(rgb: 0x666666), for: .normal)
           backgroundColor = UIColor.white
           
           titleLabel?.font = UIFont.regular(ofSize: 18)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       
       

       
       
       override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
           
           
           let x = contentRect.origin.x
           let y = (contentRect.size.height - imgSize.height)/2
           return CGRect(x: x, y: y, width: imgSize.width, height: imgSize.height)
       }
       
       
       
       override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
           let titleH: CGFloat = 24
           let x = contentRect.origin.x + imgSize.width + spacing
           let y = (contentRect.size.height - titleH)/2
           return CGRect(x: x, y: y, width: titleW, height: titleH)
          
       }

}
