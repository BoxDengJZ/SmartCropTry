//
//  ButtomViewFinal.swift
//  petit
//
//  Created by Jz D on 2021/2/3.
//  Copyright © 2021 swift. All rights reserved.
//

import UIKit

class ButtomViewFinal: UIView{

    lazy var bottomBeach: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        return v
    }()
    
    
    lazy var retakeBtn: UIButton = {
        let keBtn = UIButton()
        keBtn.setTitle("重拍", for: .normal)
        keBtn.setTitleColor(UIColor.white, for: .normal)
        keBtn.titleLabel?.font = UIFont.regular(ofSize: 16)
        keBtn.adjustsImageWhenHighlighted = false
        return keBtn
    }()
    
    lazy var rotateBtn: UIButton = {
        let neBtn = UIButton()
        neBtn.setImage(UIImage(named: "rotate_4_X"), for: .normal)
        return neBtn
    }()
    
    lazy var doneBtn: UIButton = {
        let neBtn = UIButton()
        neBtn.setImage(UIImage(named: "takenImg_4_tick"), for: .normal)
        return neBtn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        addSubs([bottomBeach, retakeBtn, doneBtn,
                 rotateBtn])
        bottomBeach.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        retakeBtn.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(40)
            m.centerY.equalTo(rotateBtn)
        }
        
        doneBtn.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalToSuperview().offset(48)
            m.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        rotateBtn.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-40)
            m.top.equalTo(bottomBeach).offset(63)
            m.size.equalTo(CGSize(width: 25, height: 25))
        }
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}



extension UIView{
    
    func addSubs(_ views: [UIView]){
        views.forEach(addSubview(_:))
    }
    
}
