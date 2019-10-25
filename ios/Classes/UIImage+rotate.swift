//
//  UIImage+rotate.swift
//  flutter_image_editor
//
//  Created by Caijinglong on 2019/10/9.
//

import Foundation

extension UIImage {
    func rotate(_ angle: Int) -> UIImage {
        // 因为如果旋转角度不是90的倍数, 则图片尺寸会发生变化, 这里使用UIView作为工具测量出旋转后的尺寸,
        let radian = CGFloat(angle) * CGFloat.pi / 180
        let measureView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let t = CGAffineTransform(rotationAngle: radian)
        measureView.transform = t
        let rect = measureView.frame

        // 使用CG开始绘制
        UIGraphicsBeginImageContext(rect.size)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return self
        }

        let origin = CGPoint(x: rect.width / 2.0,
                             y: rect.height / 2.0)

        // 开始绘制
        ctx.translateBy(x: origin.x, y: origin.y)
        ctx.rotate(by: radian)
        draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))

        guard let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        UIGraphicsEndImageContext()

        return rotatedImage
    }
}