//
//  SketchView.swift
//  pointsDrag
//
//  Created by Jz D on 2020/9/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit




protocol SketchViewProxy: class {
    func sketch(status isStart: Bool)
    
    func sketch(moving pt: CGPoint)
}



class SketchView: UIView{
    
    
    struct SketchColor{
        static let normal = UIColor(rgb: 0x43CAD5).cgColor
        static let disable = UIColor.red.cgColor
    }
    
    
    enum SketchPointOption: Int{
        case leftTop = 0, rightTop = 1, leftBottom = 2
        case rightBottom = 3
    }
    
    
    weak var delegate: SketchViewProxy?

    var currentControlPointType: SketchPointOption? = nil{
        didSet{
            if let type = currentControlPointType{
                var pts = [defaultPoints.leftTop, defaultPoints.rightTop, defaultPoints.leftBottom,
                           defaultPoints.rightBottom]
                pts.remove(at: type.rawValue)
                defaultPoints.restPoints = pts
            }
            else{
                defaultPoints.restPoints = []
            }
        }
    }
    
    var lineLayer: CAShapeLayer = {
        let l = CAShapeLayer()
        l.lineWidth = 1
        l.fillColor = UIColor.clear.cgColor
        l.strokeColor = SketchColor.normal
        return l
    }()
    
    var pointsLayer: CAShapeLayer = {
        let l = CAShapeLayer()
        l.fillColor = UIColor.white.cgColor
        l.lineWidth = 2
        l.strokeColor = SketchColor.normal
        return l
    }()
    
    var linePath: UIBezierPath = {
        let l = UIBezierPath()
        l.lineWidth = 1
        return l
    }()
    
    var pointPath: UIBezierPath = {
        let l = UIBezierPath()
        l.lineWidth = 2
        return l
    }()
    
    
    var defaultPoints = SketchModel()
    
    var ggTouch = false


    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layer.addSublayer(lineLayer)
        layer.addSublayer(pointsLayer)
        
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lineLayer.frame = bounds
        pointsLayer.frame = bounds
        
    }
    
    
    
    
    /**
     刷新数据
     */
    func reloadData(){
        linePath.removeAllPoints()
        pointPath.removeAllPoints()
        draw(sketch: defaultPoints)
        
       
        lineLayer.path = linePath.cgPath
        pointsLayer.path = pointPath.cgPath
    }
    
    
    /**
     绘制单个图形
     */
    func draw(sketch model: SketchModel){
        drawLine(with: model)
        drawPoints(with: model)
    }

    
    
    
    
    /**
      绘制四条边
     */
    func drawLine(with sketch: SketchModel){
        linePath.move(to: sketch.leftTop)
        linePath.addLine(to: sketch.rightTop)
        linePath.addLine(to: sketch.rightBottom)
        linePath.addLine(to: sketch.leftBottom)
        linePath.close()
        
    }
    
    
    
    
    /**
     绘制四个顶点
     */
    func drawPoints(with sketch: SketchModel){
        let radius: CGFloat = 8
        pointPath.move(to: sketch.leftTop.advance(radius))
        pointPath.addArc(withCenter: sketch.leftTop, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        pointPath.move(to: sketch.rightTop.advance(radius))
        pointPath.addArc(withCenter: sketch.rightTop, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        pointPath.move(to: sketch.rightBottom.advance(radius))
        pointPath.addArc(withCenter: sketch.rightBottom, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        pointPath.move(to: sketch.leftBottom.advance(radius))
        pointPath.addArc(withCenter: sketch.leftBottom, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        ///
     
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else{
            return
        }
        ggTouch = false
        
        
        let currentPoint = touch.location(in: self)
        
        // 判定选中的最大距离
        let maxDistance: CGFloat = 20
        let points = [defaultPoints.leftTop, defaultPoints.rightTop, defaultPoints.leftBottom,
                      defaultPoints.rightBottom]
        for pt in points{
            let distance = abs(pt.x - currentPoint.x) + abs(pt.y - currentPoint.y)
            if distance <= maxDistance, let pointIndex = points.firstIndex(of: pt){
                currentControlPointType = SketchPointOption(rawValue: pointIndex)
                delegate?.sketch(status: true)
                break
            }
        }
    }
    


    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if currentControlPointType != nil, let touch = touches.first{
            
            
            let current = touch.location(in: self)
            guard bounds.contains(current) else{
                return
            }
   
            
            delegate?.sketch(moving: current)
            
            let points = defaultPoints.restPoints + [current]
            let ptCount = points.count
            for i in 0...(ptCount - 2){
                for j in (i + 1)...(ptCount - 1){
                    let lhs = points[i]
                    let rhs = points[j]
                    let distance = abs(lhs.x - rhs.x) + abs(lhs.y - rhs.y)
                    if distance < 40{
                        ggTouch = true
                        break
                    }
                }
            }
            
      
            
            
            guard ggTouch == false else {
                
                return
            }
            prepare(point: current)
            
         
         
            reloadData()
        }
        
    }

    
    func prepare(point pt: CGPoint){
        if let type = currentControlPointType{
            switch type {
            case .leftTop:
                defaultPoints.leftTop = pt
            case .rightTop:
                defaultPoints.rightTop = pt
            case .leftBottom:
                defaultPoints.leftBottom = pt
            case .rightBottom:
                defaultPoints.rightBottom = pt
            }
        }
        
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        forTheFinal()
        
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        forTheFinal()

    }
    
    
    func forTheFinal(){
        delegate?.sketch(status: false)
        if defaultPoints.sortPointClockwise(){
            lineLayer.strokeColor = SketchColor.normal
            pointsLayer.strokeColor = SketchColor.normal
        }
        else{
            lineLayer.strokeColor = SketchColor.disable
            pointsLayer.strokeColor = SketchColor.disable
        }
        reloadData()
        currentControlPointType = nil
        ggTouch = false
    }
}




extension CGPoint{

    func advance(_ offsetX: CGFloat = 0, y offsetY: CGFloat = 0) -> CGPoint{
        return CGPoint(x: x+offsetX, y: y+offsetY)
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
