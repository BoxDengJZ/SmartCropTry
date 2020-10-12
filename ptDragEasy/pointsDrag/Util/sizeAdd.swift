//
//  sizeAdd.swift
//  pointsDrag
//
//  Created by Jz D on 2020/10/12.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit



extension CGSize{
    
    
    

    func size(in std: CGSize) -> CGSize{
        
        let hRatio = height / std.height
        let wRatio = width / std.width
        
        let reSolution = height / width
        
        
        print(width, height)
        
        let s: CGSize
        if hRatio > wRatio{
            s = CGSize(width: std.height / reSolution, height: std.height)
        }
        else{
            s = CGSize(width: std.width, height: std.width * reSolution)
        }
        return s
        
    }
    
    
    func size(by horizontal: CGFloat) -> CGSize{
        
       
        
        let reSolution = height / width
        
        
        print(width, height)
        
        return CGSize(width: horizontal, height: horizontal / reSolution)
       
        
    }
    
    
    func ratio(by rate: CGFloat) -> CGSize{
        return CGSize(width: width * rate, height: height * rate)
    }
    
}
