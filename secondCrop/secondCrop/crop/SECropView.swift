//
//  CropView.swift
//  CropViewController
//
//  Created by Никита Разумный on 11/5/17.
//  Copyright © 2017 resquare. All rights reserved.
//

import UIKit
import AVFoundation


struct Setting {
    static let std = Setting()
    
    let goodAreaColor = UIColor.green
    let badAreaColor  = UIColor.red
   
    let cornerSize : CGFloat = 25.0
    let cornerCount = 4
}

public class SECropView: UIView {
    
    // MARK: properties
    var areaQuadrangle = SEAreaView()
    // 四个点
    fileprivate var cornerViews = [SECornerView]()
    fileprivate var cornerOnTouch: Int? = -1
    fileprivate var imageView : UIImageView?

	var isPathValid: Bool {
        SEQuadrangleHelper.checkConvex(corners: cornerViews.map{ $0.center })
	}

    public private(set) var cornerLocations : [CGPoint]?
    var first = true
    var path: CGMutablePath {
        let path = CGMutablePath()
        guard let firstPt = cornerViews.first else {
            return path
        }
        let beginPt = CGPoint(x: firstPt.center.x - areaQuadrangle.frame.origin.x,
                             y: firstPt.center.y - areaQuadrangle.frame.origin.y)
        path.move(to: beginPt)
        for i in 1...3{
            let pt = CGPoint(x: cornerViews[i % Setting.std.cornerCount].center.x - areaQuadrangle.frame.origin.x,
                             y: cornerViews[i % Setting.std.cornerCount].center.y - areaQuadrangle.frame.origin.y)
            path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
    
    // MARK: initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
    }
    
    // MARK: layout
    
    fileprivate func pairPositionsAndViews() {
        if let cornerPositions = self.cornerLocations {
            for i in 0 ..< Setting.std.cornerCount {
                self.cornerViews[i].center = CGPoint(x: cornerPositions[i].x, y: cornerPositions[i].y)
            }
        }
        self.areaQuadrangle.fill(path: path)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let imgsize = imageView?.image?.size, let imageBounds = imageView?.bounds {
            let f = AVMakeRect(aspectRatio: imgsize, insideRect: imageBounds)
            frame = f
            areaQuadrangle.frame = bounds
        }
        self.update(scale: nil)
        
        guard first else {
            return
        }
        first = false
        let f = bounds
        let first = f.origin
        let rhsTop = CGPoint(x: first.x + f.width, y: first.y)
        let lhsHip = CGPoint(x: first.x, y: first.y + f.height)
        let end = CGPoint(x: rhsTop.x, y: lhsHip.y)
        let dots = [first, rhsTop, end, lhsHip]
        self.cornerLocations = dots
        areaQuadrangle.frame = bounds
        update(scale: nil)
        cornerOnTouch = nil
    }
    
    public func configure(corners imageView: UIImageView) {
        
        self.imageView = imageView
        self.imageView?.isUserInteractionEnabled = true
        imageView.addSubview(self)
        
        for subview in subviews {
            if subview is SECornerView {
                subview.removeFromSuperview()
            }
        }
        
        for _ in 0..<Setting.std.cornerCount {
            let corner = SECornerView(frame: CGRect(x: 0, y: 0, width: Setting.std.cornerSize, height: Setting.std.cornerSize))
            addSubview(corner)
            cornerViews.append(corner)
        }
        areaQuadrangle.backgroundColor = .clear
        addSubview(areaQuadrangle)
    }
    
    public
    func refresh(corners dots: [CGPoint]) {
        for i in 0 ..< Setting.std.cornerCount {
            cornerLocations?[i] = dots[i]
        }
        cornerOnTouch = -1
        update(scale: nil)
        for i in 0 ..< Setting.std.cornerCount {
            cornerViews[i].layer.borderColor = (isPathValid ? Setting.std.goodAreaColor : Setting.std.badAreaColor ).cgColor
        }
        cornerOnTouch = nil
    }
    
    fileprivate func update(scale isBigger: Bool?) {
        guard let touchIdx = cornerOnTouch else {
            return
        }
        pairPositionsAndViews()
        if let bigger = isBigger{
            switch bigger {
            case true:
                cornerViews[touchIdx].scaleUp()
            case false:
                cornerViews[touchIdx].scaleDown()
            }
        }
        for corner in cornerViews {
            corner.layer.borderColor = (isPathValid ? Setting.std.goodAreaColor : Setting.std.badAreaColor).cgColor
        }
    }

    // MARK: touches handling
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1, let first = touches.first else {
            return
        }
        let point = first.location(in: self)
        var bestDistance: CGFloat = 1000.0 * 1000.0 * 1000.0
        
        for i in 0 ..< Setting.std.cornerCount {
            let tmpPoint = cornerViews[i].center
            let distance : CGFloat =
                (point.x - tmpPoint.x) * (point.x - tmpPoint.x) +
                (point.y - tmpPoint.y) * (point.y - tmpPoint.y)
            if distance < bestDistance {
                bestDistance = distance
                cornerOnTouch = i
            }
        }
        update(scale: true)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touchIdx = cornerOnTouch, touches.count == 1, let first = touches.first, let cornerLocations = cornerLocations, let img = imageView?.image else { return }
        let from = first.previousLocation(in: self)
        let to = first.location(in: self)
        let derivative = CGPoint(x: to.x - from.x, y: to.y - from.y)
        
        let rawPt = CGPoint(x: cornerLocations[touchIdx].x + derivative.x, y: cornerLocations[touchIdx].y + derivative.y)
        let newCenterOnImage = rawPt.normalized(size: img.size)
        self.cornerLocations?[touchIdx] = newCenterOnImage
        print(newCenterOnImage)
        
        update(scale: nil)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard cornerOnTouch != nil, touches.count == 1 else {
            return
        }
        sortPointClockwise()
        update(scale: false)
        cornerOnTouch = nil
    }
    
    
    
    
    func sortPointClockwise(){
         // 按左上，右上，右下，左下排序
        var result = [CGPoint](repeating: CGPoint.zero, count: 4)
        var minDistance: CGFloat = -1
        guard let pts = cornerLocations else { return }
        for p in pts{
            let distance = p.x * p.x + p.y * p.y
            if minDistance == -1 || distance < minDistance{
                result[0] = p
                minDistance = distance
            }
        }
        var leftPts = pts.filter { (pp) -> Bool in
            pp != result[0]
        }
        if leftPts[1].pointSideLine(left: result[0], right: leftPts[0]) * leftPts[2].pointSideLine(left: result[0], right: leftPts[0]) < 0{
            result[2] = leftPts[0]
        }
        else if leftPts[0].pointSideLine(left: result[0], right: leftPts[1]) * leftPts[2].pointSideLine(left: result[0], right: leftPts[1]) < 0{
            result[2] = leftPts[1]
        }
        else if leftPts[0].pointSideLine(left: result[0], right: leftPts[2]) * leftPts[1].pointSideLine(left: result[0], right: leftPts[2]) < 0{
            result[2] = leftPts[2]
        }
        leftPts = pts.filter { (pt) -> Bool in
            pt != result[0] && pt != result[2]
        }
        if leftPts[0].pointSideLine(left: result[0], right: result[2]) > 0{
            result[1] = leftPts[0]
            result[3] = leftPts[1]
        }
        else{
            result[1] = leftPts[1]
            result[3] = leftPts[0]
        }
        if result[0].gimpTransformPolygon(isConvex: result[1], two: result[3], three: result[2]){
            cornerLocations = result
        }
        
    }
}



extension CGPoint{
    
    func pointSideLine(left lhs: CGPoint, right rhs: CGPoint) -> CGFloat{
        return (x - lhs.x) * (rhs.y - lhs.y) - (y - lhs.y) * (rhs.x - lhs.x)
    }

    
    func gimpTransformPolygon(isConvex firstPt: CGPoint, two twicePt: CGPoint, three thirdPt: CGPoint) -> Bool{
        
        let x2 = firstPt.x, y2 = firstPt.y
        let x3 = twicePt.x, y3 = twicePt.y
        let x4 = thirdPt.x, y4 = thirdPt.y
     
        let z1 = ((x2 - x) * (y4 - y) - (x4 - x) * (y2 - y))
        let z2 = ((x4 - x) * (y3 - y) - (x3 - x) * (y4 - y))
        let z3 = ((x4 - x2) * (y3 - y2) - (x3 - x2) * (y4 - y2))
        let z4 = ((x3 - x2) * (y - y2) - (x - x2) * (y3 - y2))
     
        return (z1 * z2 > 0) && (z3 * z4 > 0)
    }
}
