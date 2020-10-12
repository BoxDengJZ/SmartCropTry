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
    
    
    init() {
       
        let screenH = UIScreen.main.bounds.height
        let screenW = UIScreen.main.bounds.width
        
        h = screenH - 160
        
        
        w = min(screenW - 80, h - 40)
        
        center = CGPoint(x: screenW * 0.5, y: screenH * 0.5)
        
        s = CGSize(width: w, height: h)
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
    
    lazy var magnifierV = MagnifierView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - magnifieViewWH * 1.5, width: magnifieViewWH, height: magnifieViewWH))

    
    lazy var measure = ImgLayout()
    
    
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
