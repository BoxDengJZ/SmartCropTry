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
    fileprivate var corners = [SECornerView]()
    fileprivate var cornerOnTouch = -1
    fileprivate var imageView : UIImageView?

	var isPathvalid: Bool {
		areaQuadrangle.isPathValid
	}

    public private(set) var cornerLocations : [CGPoint]?
    
    var path : CGMutablePath {
        let path = CGMutablePath()
        guard let firstPt = corners.first else {
            return CGMutablePath()
        }
        
        let beginPt = CGPoint(x: firstPt.center.x - areaQuadrangle.frame.origin.x,
                             y: firstPt.center.y - areaQuadrangle.frame.origin.y)
        path.move(to: beginPt)
        for i in 1...3{
            let pt = CGPoint(x: corners[i % Setting.std.cornerCount].center.x - areaQuadrangle.frame.origin.x,
                             y: corners[i % Setting.std.cornerCount].center.y - areaQuadrangle.frame.origin.y)
            path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
    
    public var cornersLocationOnView : [CGPoint]? {
        guard let imageSize = imageView?.image?.size else { return nil }
        guard let imageViewFrame = imageView?.bounds else { return nil }
        guard let imageViewOrigin = imageView?.globalPoint else { return nil }
        guard let cropViewOrigin = self.globalPoint else { return nil }
        guard let cornersOnImage = cornerLocations else { return nil }
        
        let imageOrigin = AVMakeRect(aspectRatio: imageSize, insideRect: imageViewFrame).origin
        let shiftX = -cropViewOrigin.x + imageViewOrigin.x + imageOrigin.x + Setting.std.cornerSize / 2.0
        let shiftY = -cropViewOrigin.y + imageViewOrigin.y + imageOrigin.y + Setting.std.cornerSize / 2.0
        let shift = CGPoint(x: shiftX, y: shiftY)
        
        let pts = cornersOnImage.map {
            CGPoint(x: $0.x + shift.x, y: $0.y + shift.y)
        }
        
        print("pts: ", pts)
        return pts
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
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // MARK: layout
    
    fileprivate func pairPositionsAndViews() {
        DispatchQueue.main.async {
            
            if let cornerPositions = self.cornersLocationOnView {
                for i in 0 ..< Setting.std.cornerCount {
                    self.corners[i].center = CGPoint(x: cornerPositions[i].x - Setting.std.cornerSize / 2.0,
                                                y: cornerPositions[i].y - Setting.std.cornerSize / 2.0)
                    self.corners[i].setNeedsDisplay()
                }
            }
            self.areaQuadrangle.setNeedsDisplay()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)
        if let imgsize = imageView?.image?.size, let imageBounds = imageView?.bounds {
            let imageOrigin = AVMakeRect(aspectRatio: imgsize, insideRect: imageBounds)
            frame = imageOrigin
            areaQuadrangle.frame = AVMakeRect(aspectRatio: imgsize, insideRect: bounds)
        }
        self.pairPositionsAndViews()
        self.update(scale: 0)
        setNeedsDisplay()
    }
    
    public func configureWithCorners(on imageView: UIImageView) {
        let f = imageView.bounds
        let first = f.origin
        let rhsTop = CGPoint(x: first.x + f.width, y: first.y)
        let lhsHip = CGPoint(x: first.x, y: first.y + f.height)
        let end = CGPoint(x: rhsTop.x, y: lhsHip.y)
        let corners = [first, rhsTop, end, lhsHip]
        self.cornerLocations = corners
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
            self.corners.append(corner)
        }
        areaQuadrangle.frame = bounds
        areaQuadrangle.backgroundColor = .clear
        areaQuadrangle.cropView = self
        
        areaQuadrangle.isPathValid = SEQuadrangleHelper.checkConvex(corners: corners)
        addSubview(areaQuadrangle)
        for corner in self.corners {
            corner.layer.borderColor = (areaQuadrangle.isPathValid ? Setting.std.goodAreaColor : Setting.std.badAreaColor ).cgColor
            corner.scaleDown()
        }
        areaQuadrangle.setNeedsDisplay()
        layoutSubviews()
    }
    
    public func setCorners(newCorners: [CGPoint]) {
		areaQuadrangle.isPathValid = SEQuadrangleHelper.checkConvex(corners: newCorners)
        for i in 0 ..< Setting.std.cornerCount {
            cornerLocations?[i] = newCorners[i]
			corners[i].layer.borderColor = (areaQuadrangle.isPathValid ? Setting.std.goodAreaColor : Setting.std.badAreaColor ).cgColor
        }
        pairPositionsAndViews()
        setNeedsDisplay()
    }
    
    fileprivate func update(scale : Int) {
        guard self.cornerOnTouch != -1 else { return }
        switch scale {
        case 1:
            self.corners[self.cornerOnTouch].scaleUp()
            self.bringSubviewToFront(self.corners[self.cornerOnTouch])
            self.bringSubviewToFront(self.areaQuadrangle)
        case -1:
            self.corners[self.cornerOnTouch].scaleDown()
        default: break
        }
        
        self.corners[self.cornerOnTouch].setNeedsDisplay()
        self.areaQuadrangle.isPathValid = SEQuadrangleHelper.checkConvex(corners: self.corners.map{ $0.center })
        for corner in self.corners {
            corner.layer.borderColor = (self.areaQuadrangle.isPathValid ? Setting.std.goodAreaColor : Setting.std.badAreaColor).cgColor
        }
    }

    // MARK: touches handling
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1 else {
            return
        }
        let point = touches.first!.location(in: self)
        
        var bestDistance : CGFloat = 1000.0 * 1000.0 * 1000.0
        
        for i in 0 ..< Setting.std.cornerCount {
            let tmpPoint = corners[i].center
            let distance : CGFloat =
                (point.x - tmpPoint.x) * (point.x - tmpPoint.x) +
                (point.y - tmpPoint.y) * (point.y - tmpPoint.y)
            if distance < bestDistance {
                bestDistance = distance
                cornerOnTouch = i
            }
        }
        update(scale: 1)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard cornerOnTouch != -1 && touches.count == 1 else {
            return
        }
        
        let from = touches.first!.previousLocation(in: self)
        let to = touches.first!.location(in: self)
        
        let derivative = CGPoint(x: to.x - from.x, y: to.y - from.y)
        
        update(scale: 0)

        guard let cornerLocations = cornerLocations else { return }
        guard let img = imageView?.image else { return }
        let newCenterOnImage = CGPoint(x: cornerLocations[cornerOnTouch].x + derivative.x,
                                       y: cornerLocations[cornerOnTouch].y + derivative.y).normalized(size: CGSize(width: img.size.width * img.scale,
                                                                                                                             height: img.size.height * img.scale))
        self.cornerLocations?[cornerOnTouch] = newCenterOnImage
        print(newCenterOnImage)
        
        pairPositionsAndViews()
        areaQuadrangle.setNeedsDisplay()
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard cornerOnTouch != -1 && touches.count == 1 else {
            return
        }
        update(scale: -1)
        cornerOnTouch = -1
    }
}
