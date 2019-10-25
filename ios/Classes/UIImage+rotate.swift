//
//  UIImage+rotate.swift
//  flutter_image_editor
//
//  Created by Caijinglong on 2019/10/9.
//

import Foundation

extension UIImage {
    func rotate(_ angle: Int) -> UIImage {
//        // 转为弧度制
        let radian = CGFloat(angle) * CGFloat.pi / 180
        return rotate(radians: radian)
    }

    func rotate(radians: CGFloat) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: size).applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: radians)
        // Draw the image at its center
        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }

        UIGraphicsEndImageContext()

        return newImage
    }
}