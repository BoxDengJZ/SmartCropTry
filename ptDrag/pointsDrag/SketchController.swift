//
//  ViewController.swift
//  pointsDrag
//
//  Created by Jz D on 2020/9/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit



struct ImgLayout {
    
    static let std = ImgLayout()
    
    let w: CGFloat
    
    let h: CGFloat
    
    let center: CGPoint
    
    let s: CGSize
    
    let horizontal: CGFloat
    
    let screenH: CGFloat
    
    let screenW: CGFloat
    
    
    
    init() {
       
        screenH = UIScreen.main.bounds.height
        screenW = UIScreen.main.bounds.width
        
        h = screenH - 160
        
        
        w = min(screenW - 80, h - 40)
        
        center = CGPoint(x: screenW * 0.5, y: screenH * 0.5)
        
        s = CGSize(width: w, height: h)
        
        horizontal = w
        
    }
    
    
    

}




class SketchController: UIViewController {
    
    var image: UIImage?
    
    lazy var imgView = UIImageView(image: image)
    
    lazy var sketch: SketchView = {
        let sk = SketchView()
        sk.delegate = self
        sk.layer.borderColor = UIColor.green.cgColor
        sk.layer.borderWidth = 2
        return sk
    }()
    
    let magnifieViewWH : CGFloat = 150
    
    lazy var magnifierV = MagnifierView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - magnifieViewWH * 1.5, width: magnifieViewWH, height: magnifieViewWH))

    
    lazy var measure = ImgLayout()
    
    
    lazy var lhsRotateB = DirectionRotateB(opt: .lhs)
    
    lazy var rhsRotateB = DirectionRotateB(opt: .rhs)
    
    
    var angle: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
    
        if let img = image{
            let s = img.size.size(in: measure.s)
        
            imgView.frame.size = s
            imgView.center = measure.center
            sketch.frame = imgView.frame
            view.addSubview(imgView)
            view.addSubview(sketch)
            sketch.reloadData()
            
            
            magnifierV.renderView = imgView
            view.addSubview(magnifierV)
        }
        
        
        view.addSubview(lhsRotateB)
        view.addSubview(rhsRotateB)
        let sizeB = CGSize(width: 74, height: 32)
        lhsRotateB.frame.size = sizeB
        rhsRotateB.frame.size = sizeB
        
        lhsRotateB.center = CGPoint(x: 50, y: measure.screenH - sizeB.height - 20)
        rhsRotateB.center = CGPoint(x: measure.screenW - sizeB.width - 50, y: measure.screenH - sizeB.height - 20)
        
        lhsRotateB.addTarget(self, action: #selector(leftTurn), for: .touchUpInside)
        rhsRotateB.addTarget(self, action: #selector(rightTurn), for: .touchUpInside)
    }

    
    @objc func leftTurn(){
        rotate(with: .lhs)
    }
    
    
    
    @objc func rightTurn(){
        rotate(with: .rhs)
    }
    
    
    
    func rotate(with direction: RotateOpt) {
        guard let img = image else {
            return
        }
        let sizeOld = sketch.frame.size
        let originOld = sketch.frame.origin
        let center = sketch.center
        let sizeNew = CGSize(width: sizeOld.height, height: sizeOld.width)
        
        
        
        switch direction {
        case .lhs:
            
            // 逆时针
            
            angle -= 1
            
            
            sketch.defaultPoints.update(clockwize: false, by: sizeOld)
        case .rhs:
            
            // 顺时针
            
            angle += 1
            
            sketch.defaultPoints.update(clockwize: true, by: sizeOld)
            // 下一步，对 UI 的修改，影响上一步
            
        }
        
        
        
        let ratio: CGFloat
        
        let smallS = img.size.size(by: measure.horizontal)
        let bigS = img.size.size(in: measure.s)
        if Int(angle) % 2 == 0{
            ratio = smallS.width / bigS.height
            
            imgView.transform = CGAffineTransform(rotationAngle: ImgSingleAngle.time * angle).scaledBy(x: ratio, y: ratio)
            sketch.frame.size = sizeNew.ratio(by: ratio)
        }
        else{
            ratio = bigS.height / smallS.width
            imgView.transform = CGAffineTransform(rotationAngle: ImgSingleAngle.time * angle).scaledBy(x: ratio, y: ratio)
            sketch.frame.size = sizeNew.ratio(by: ratio)
        }
            
        print("ratio", ratio)
       
        sketch.center = center
        let originNew = sketch.frame.origin
        
        sketch.defaultPoints.patch(vector: originNew - originOld)
        
        
        sketch.defaultPoints.scale(r: ratio)
        
        
        
        sketch.reloadData()
        
    }

}




extension SketchController: SketchViewProxy{

    
    func sketch(status isStart: Bool) {
        magnifierV.isHidden = (isStart == false)
    }
    
    func sketch(moving pt: CGPoint) {
        // 设置渲染的中心点
        magnifierV.renderPoint = pt
    }
    
}



struct ImgSingleAngle {
    static let time = CGFloat.pi * 0.5
}
