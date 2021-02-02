//
//  UIView+globalCoordinates.swift
//  CropView
//
//  Created by Никита Разумный on 2/3/18.
//

import UIKit

extension UIView {
    var globalPoint :CGPoint? {
        superview?.convert(frame.origin, to: nil)
    }
    var globalFrame :CGRect? {
        superview?.convert(frame, to: nil)
    }
}
