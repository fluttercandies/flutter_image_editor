//
//  UIImage+rotate.swift
//  flutter_image_editor
//
//  Created by Caijinglong on 2019/10/9.
//

import Foundation

extension UIImage {
    func rotate(_ angle: Int) -> UIImage {
        // 转为弧度制
        let radian = CGFloat(angle) * CGFloat.pi / 180
        
        // 计算出旋转后需要的尺寸, 因为非180度的倍数会发生宽高变化, 非90的整数倍会使用白色填充背景色
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radian)))
            .integral.size

        // 使用CG开始绘制
        UIGraphicsBeginImageContext(rotatedSize)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return self
        }

        let origin = CGPoint(x: rotatedSize.width / 2.0,
                             y: rotatedSize.height / 2.0)

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
