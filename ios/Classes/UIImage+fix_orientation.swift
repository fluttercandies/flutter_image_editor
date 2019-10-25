//
//  UIImage+fix_orientation.swift
//  image_editor
//
//  Created by Caijinglong on 2019/10/24.
//

import Foundation

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        draw(in: CGRect(origin: .zero, size: size))

        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }

        UIGraphicsEndImageContext()

        return result
    }
}