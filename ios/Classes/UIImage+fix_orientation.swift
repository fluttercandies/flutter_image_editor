//
//  UIImage+fix_orientation.swift
//  image_editor
//
//  Created by Caijinglong on 2019/10/24.
//

import Foundation

extension UIImage{
    
    func fixOrientation() -> UIImage{
        if self.imageOrientation == .up{
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        draw(in: CGRect(origin: .zero, size: self.size))
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
}
