//
//  SketchModel.swift
//  pointsDrag
//
//  Created by Jz D on 2020/9/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit






struct SketchModel{
    var leftTop: CGPoint
    var rightTop: CGPoint
    var leftBottom: CGPoint
    var rightBottom: CGPoint
    
    var restPoints = [CGPoint]()
    
    
    
    var pts: [CGPoint]{
        [leftTop, rightTop, leftBottom, rightBottom]
    }
    
  
    
    
    
    
    init() {
        leftTop = CGPoint(x: 10, y: 10).advance(50)
        
        rightTop = CGPoint(x: 100, y: 10).advance(y: 50)
        
        
        leftBottom = CGPoint(x: 10, y: 100).advance(y: -50)
        
        rightBottom = CGPoint(x: 100, y: 100).advance(-50)
    }
    

    mutating
    func sortPointClockwise() -> Bool{
         // 按左上，右上，右下，左下排序
        var result = [CGPoint](repeating: CGPoint.zero, count: 4)
        var minDistance: CGFloat = -1
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
            leftTop = result[0]
            rightTop = result[1]
            
            rightBottom = result[2]
            leftBottom = result[3]
            return true
        }
        else{
            return false
        }
        
    }
    
    
    
    
    mutating
    func update(clockwize beC: Bool, by area: CGSize){
        let lhsTop: CGPoint, rhsTop: CGPoint, rhsBottom: CGPoint, lhsBottom: CGPoint
        let center = CGPoint(x: area.width / 2, y: area.height / 2 )
        if beC{
            lhsTop = clockwize(rightTurn: leftTop, forCoordinate: center)
               
            rhsTop = clockwize(rightTurn: rightTop, forCoordinate: center)
                
            rhsBottom = clockwize(rightTurn: rightBottom, forCoordinate: center)
                
            lhsBottom = clockwize(rightTurn: leftBottom, forCoordinate: center)
        }
        else{
            lhsTop = antiClockwize(leftTurn: leftTop, forCoordinate: center)
            rhsTop = antiClockwize(leftTurn: rightTop, forCoordinate: center)
            rhsBottom = antiClockwize(leftTurn: rightBottom, forCoordinate: center)
            lhsBottom = antiClockwize(leftTurn: leftBottom, forCoordinate: center)
        }
        leftTop = lhsTop
        rightTop = rhsTop
        
        rightBottom = rhsBottom
        leftBottom = lhsBottom
        
       
    }
    
    
    
     mutating
     func patch(vector pt: CGPoint){
          
          leftTop = leftTop - pt
          rightTop = rightTop - pt
           
          rightBottom = rightBottom - pt
          leftBottom = leftBottom - pt
          
          
          
      }
    
      
      mutating
      func scale(r ratio: CGFloat, forS size: CGSize){
            leftTop.scale(by: ratio, forS: size)
            rightTop.scale(by: ratio, forS: size)
            rightBottom.scale(by: ratio, forS: size)
            leftBottom.scale(by: ratio, forS: size)
      }
    
      
    
      private
      func clockwize(rightTurn target: CGPoint, forCoordinate origin: CGPoint) -> CGPoint {
          let dx = target.x - origin.x
          let dy = target.y - origin.y
          let radius = sqrt(dx * dx + dy * dy)
          let azimuth = atan2(dy, dx) // in radians
          let x = origin.x - radius * sin(azimuth)
          let y = origin.y + radius * cos(azimuth)
          return CGPoint(x: x, y: y)
      }
      
      
      private
      func antiClockwize(leftTurn target: CGPoint, forCoordinate origin: CGPoint) -> CGPoint {
          let dx = target.x - origin.x
          let dy = target.y - origin.y
          let radius = sqrt(dx * dx + dy * dy)
          let azimuth = atan2(dy, dx) // in radians
         
          let x = origin.x + radius * sin(azimuth)
          let y = origin.y - radius * cos(azimuth)
          return CGPoint(x: x, y: y)
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




