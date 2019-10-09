//
//  UIImage+rotate.swift
//  flutter_image_editor
//
//  Created by Caijinglong on 2019/10/9.
//

import Foundation

extension UIImage {
    func rotate(_ angle: Int) -> UIImage {
        let radian = CGFloat(angle) * CGFloat.pi / 180

        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext(), let oldCgImage = cgImage else {
            return self
        }

        // 因为如果旋转角度不是90的倍数, 则图片尺寸会发生变化, 这里使用UIView作为工具测量出旋转后的尺寸,
        let measureView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let t = CGAffineTransform(rotationAngle: radian)
        measureView.transform = t
        let rect = measureView.frame

        // 开始绘制
        ctx.translateBy(x: rect.width / 2, y: rect.height / 2)
        ctx.rotate(by: radian)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(oldCgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

        guard let cgImg = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return self
        }
        UIGraphicsEndImageContext()
        return UIImage(cgImage: cgImg, scale: 1, orientation: imageOrientation)
    }
}