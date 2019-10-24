//
//  UIImage+flip.swift
//  flutter_image_editor
//
//  Created by Caijinglong on 2019/10/9.
//

import UIKit

extension UIImage {
    func flip(horizontal: Bool, vertical: Bool) -> UIImage {
        if !horizontal, !vertical{
            return self
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return self
        }

        guard let cgImage = self.cgImage else {
            return self
        }

        ctx.clip(to: rect)

        if !vertical, horizontal {
            // 仅水平翻转, 因为默认是垂直翻转状态, 所以先水平翻转, 然后
            ctx.rotate(by: .pi)
            ctx.translateBy(x: -rect.size.width, y: -rect.size.height)
        } else if vertical, !horizontal {
            // 仅垂直翻转, 和 CG 体系的默认情况一致, 不操作
        } else if vertical, horizontal {
            // 水平+垂直, 因为默认情况下是垂直翻转, 这里仅水平翻转即可, 虽然这么写,但是实际上开头就直接返回self
            ctx.translateBy(x: rect.size.width, y: 0)
            ctx.scaleBy(x: -1, y: 1)
        } else {
            // 无操作时, 需要将垂直坐标系翻转
            ctx.translateBy(x: 0, y: rect.size.height)
            ctx.scaleBy(x: 1, y: -1)
        }

        ctx.draw(cgImage, in: rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        UIGraphicsEndImageContext()

        guard let cg = image.cgImage else {
            return self
        }

        return UIImage(cgImage: cg, scale: 1, orientation: imageOrientation)
    }
}

extension Double {
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}
