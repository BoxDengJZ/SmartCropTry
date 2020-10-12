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
        
        center = CGPoint(x: screenW * 0.5, y: screenH * 0.5 + 40)
        
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
        return sk
    }()
    
    let magnifieViewWH : CGFloat = 150
    
    lazy var magnifierV = MagnifierView(frame: CGRect(x: 20, y: 20, width: magnifieViewWH, height: magnifieViewWH))

    
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
        
        let imgRatio = img.size.height / img.size.width
        let const = 4.0/3
        print(imgRatio, const)
        
        let sizeOld = sketch.frame.size
        let originOld = sketch.frame.origin
        let center = sketch.center
        let bigS = img.size.size(in: measure.s)
        let clockwize: Bool
        switch direction {
        case .lhs:
            
            // 逆时针
            
            angle -= 1
            clockwize = false
            
            
        case .rhs:
            
            // 顺时针
            
            angle += 1
            clockwize = true
            
            // 下一步，对 UI 的修改，影响上一步
            
        }
        
        
        
        var ratio: CGFloat = 1
        
        let smallS = img.size.size(by: measure.horizontal)
        
        var imgTransform = CGAffineTransform(rotationAngle: ImgSingleAngle.time * angle)
        if Int(angle) % 2 == 1{
            ratio = smallS.width / bigS.height
            imgTransform = imgTransform.scaledBy(x: ratio, y: ratio)
            sketch.frame.size = smallS
           
        }
        else{
            ratio = bigS.height / smallS.width
            sketch.frame.size = bigS
            
        }
     
        // 旋转四个拖拽的点之前，先复位
        
        // 小的，变大的，的时候，需要操作
        if Int(angle) % 2 == 0{
            print("1/ratio", 1/ratio)
            sketch.defaultPoints.scale(r: ratio, forS: sizeOld)
        }
        sketch.defaultPoints.update(clockwize: clockwize, by: sizeOld)
        imgView.transform = imgTransform
        
       
        sketch.center = center
        let originNew = sketch.frame.origin
        
        sketch.defaultPoints.patch(vector: originNew - originOld)
        
        
        //  四个拖拽的点， 属于正常标准的图片
        
        // 横着摆放，大变小
        if Int(angle) % 2 == 1{
            print("ratio", ratio)
            sketch.defaultPoints.scale(r: ratio, forS: sizeOld)
        }
        
        
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
