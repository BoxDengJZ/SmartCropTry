//
//  ViewController.swift
//  pointsDrag
//
//  Created by Jz D on 2020/9/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var image = UIImage(named: "sample.jpg")
    
    lazy var imgView = UIImageView(image: image)
    
    lazy var sketch: SketchView = {
        let sk = SketchView()
        sk.delegate = self
        return sk
    }()
    
    let magnifieViewWH : CGFloat = 150
    
    lazy var magnifierV = MagnifierView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - magnifieViewWH * 1.5, width: magnifieViewWH, height: magnifieViewWH))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let maxHeight = view.frame.size.height - 240
        if let img = image{
            let maxWidth = maxHeight / img.size.height * img.size.width
            let width = min(view.frame.size.width, maxWidth)
            let height = width / img.size.width * img.size.height
            let f = CGRect(x: (view.frame.size.width - width) / 2, y: 80, width: width, height: height)
            imgView.frame = f
            sketch.frame = f
            view.addSubview(imgView)
            view.addSubview(sketch)
            sketch.reloadData()
            
            
            magnifierV.renderView = imgView
            view.addSubview(magnifierV)
        }
        
        
    }


}




extension ViewController: SketchViewProxy{

    
    func sketch(status isStart: Bool) {
        magnifierV.isHidden = (isStart == false)
    }
    
    func sketch(moving pt: CGPoint) {
        // 设置渲染的中心点
        magnifierV.renderPoint = pt
    }
    
}
