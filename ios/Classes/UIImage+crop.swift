//
//  UIImage+crop.swift
//  flutter_image_editor
//
//  Created by Caijinglong on 2019/10/9.
//

import Foundation

extension UIImage {
    func crop(x: Int, y: Int, width: Int, height: Int) -> UIImage {
        guard let cg = self.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height)) else {
            return self
        }
        
        return UIImage(cgImage: cg)
    }
}
