//
//  UIImageAdd.swift
//  musicSheet
//
//  Created by Jz D on 2019/9/9.
//  Copyright © 2019 Jz D. All rights reserved.
//

import UIKit

extension UIImage{    
    var aspestRatio: CGFloat{
        return size.height/size.width
    }
    
    
    static let defaultRatio: CGFloat = 1.0/6.0
}



extension UIImage{



    static func qrCode(info txt: String) -> UIImage?{
        let data = txt.data(using: String.Encoding.utf8)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
        
    }




}



extension UIImage{
    var disabled: UIImage?{
        let ciImage = CIImage(image: self)
        let grayscale = ciImage?.applyingFilter("CIColorControls",
                                                parameters: [ kCIInputSaturationKey: 0.0 ])
        if let gray = grayscale{
            return UIImage(ciImage: gray)
        }
        else{
            return nil
        }
    }
}




extension UIImage{
    /// Create a grayscale image with alpha channel. Is 5 times faster than grayscaleImage().
    /// - Returns: The grayscale image of self if available.
    var grayScaled: UIImage?
    {
        // Create image rectangle with current image width/height * scale
        let pixelSize = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        let imageRect = CGRect(origin: CGPoint.zero, size: pixelSize)
        // Grayscale color space
        
        
        // 核心方法，是通过颜色空间
         let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()

            // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        if let context: CGContext = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            {
                // Draw image into current context, with specified rectangle
                // using previously defined context (with grayscale colorspace)
                guard let cg = self.cgImage else{
                    return nil
                }
                context.draw(cg, in: imageRect)
                // Create bitmap image info from pixel data in current context
                if let imageRef: CGImage = context.makeImage(){
                    let bitmapInfoAlphaOnly = CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue)

                    guard let context = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfoAlphaOnly.rawValue) else{
                        return nil
                    }
                    context.draw(cg, in: imageRect)
                    if let mask: CGImage = context.makeImage() {
                        // Create a new UIImage object
                        if let newCGImage = imageRef.masking(mask){
                            // Return the new grayscale image
                            return UIImage(cgImage: newCGImage, scale: self.scale, orientation: self.imageOrientation)
                        }
                    }

                }
            }


        // A required variable was unexpected nil
        return nil
    }
}




extension UIImage{
    
    
    func image(rotated time: Int) -> UIImage{
        guard time != 0 else {
            return self
        }
        return rotate(degress: CGFloat(time) * .pi / 2)
      
    }
    
    
    
    func rotate(degress: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform(rotationAngle: degress)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size

        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()

        bitmap?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)

        bitmap?.rotate(by: degress)

        bitmap?.scaleBy(x: 1.0, y: -1.0)
        guard let cgImg = self.cgImage else {
            return self
        }
        bitmap?.draw(cgImg, in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
    
    
    var up: UIImage{
        image(orientation: .up)
    }
    
    var down: UIImage{
        image(orientation: .down)
    }
    
    
    var left: UIImage{
        image(orientation: .left)
    }
    
    var right: UIImage{
        image(orientation: .right)
    }
    
    var isUp: Bool{
        check(orientation: .up)
    }
    
    var isDown: Bool{
        check(orientation: .down)
    }
    
    
    var isLeft: Bool{
        check(orientation: .left)
    }
    
    
    var isRight: Bool{
        check(orientation: .right)
    }
    
    
    func image(orientation orient: UIImage.Orientation) -> UIImage{
        if let cg = cgImage{
            return UIImage(cgImage: cg, scale: scale, orientation: orient)
        }
        else{
            return self
        }
    }
    
    
    func check(orientation orient: UIImage.Orientation) -> Bool{
        imageOrientation == orient
    }
    
    
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}




extension CGFloat{
    var radian: CGFloat{
        self * CGFloat.pi / 180
    }
}
