//
//  ZLGeneralDefine.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//
//  Copyright (c) 2020 Long Zhang <longitachi@163.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

let ZLMaxImageWidth: CGFloat = 600

struct ZLLayout {
    
    static let navTitleFont = getFont(17)
    
    static let bottomToolViewH: CGFloat = 55
    
    static let bottomToolBtnH: CGFloat = 34
    
    static let bottomToolTitleFont = getFont(17)
    
    static let bottomToolBtnCornerRadius: CGFloat = 5
    
    static let thumbCollectionViewItemSpacing: CGFloat = 2
    
    static let thumbCollectionViewLineSpacing: CGFloat = 2
    
}

func zlRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
}


func getFont(_ size: CGFloat) -> UIFont {
    guard let name = ZLCustomFontDeploy.fontName else {
        return UIFont.systemFont(ofSize: size)
    }
    
    return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
}

func getAppName() -> String {
    if let name = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
        return name
    }
    if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
        return name
    }
    return "App"
}



func getSpringAnimation() -> CAKeyframeAnimation {
    let animate = CAKeyframeAnimation(keyPath: "transform")
    animate.duration = 0.3
    animate.isRemovedOnCompletion = true
    animate.fillMode = .forwards
    
    animate.values = [CATransform3DMakeScale(0.7, 0.7, 1),
                      CATransform3DMakeScale(1.2, 1.2, 1),
                      CATransform3DMakeScale(0.8, 0.8, 1),
                      CATransform3DMakeScale(1, 1, 1)]
    return animate
}


func zl_debugPrint(_ message: Any) {
//    debugPrint(message)
}
