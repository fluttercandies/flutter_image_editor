//
// Created by Caijinglong on 2019-10-09.
//

import Foundation
import UIKit

class UIImageHandler {
    var image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    func handleImage(options: [FlutterImageEditorOption], fixOrientation: Bool = true) {
        if fixOrientation {
            let orientation = image.imageOrientation
            switch orientation {
            case .up:
                break
            case .down:
                image = image.rotate(180)
            case .left:
                image = image.rotate(270)
            case .right:
                image = image.rotate(90)
            case .upMirrored:
                image = image.flip(horizontal: true, vertical: false)
            case .downMirrored:
                image = image.flip(horizontal: false, vertical: true)
            case .leftMirrored:
                image = image.rotate(90)
                image = image.flip(horizontal: true, vertical: false)
            case .rightMirrored:
                image = image.rotate(270)
                image = image.flip(horizontal: true, vertical: false)
            }
        }

        for option in options {
            if option is FlipOption {
                image = handleFlip(option as! FlipOption)
            } else if option is ClipOption {
                image = handleClip(option as! ClipOption)
            } else if option is RotateOption {
                image = handleRotate(option as! RotateOption)
            }
        }
    }

    func outputFile(targetPath: String, format: FormatOption) {
        let data = outputMemory(format: format)
        try! data?.write(to: URL(fileURLWithPath: targetPath))
    }

    func outputMemory(format: FormatOption) -> Data? {
        if format.format == 0 {
            return UIImagePNGRepresentation(image)
        } else {
            return UIImageJPEGRepresentation(image, CGFloat(format.quality) / 100)
        }
    }

    private func handleRotate(_ option: RotateOption) -> UIImage {
        return image.rotate(option.degree)
    }

    private func handleClip(_ option: ClipOption) -> UIImage {
        return image.crop(x: option.x, y: option.y, width: option.width, height: option.height)
    }

    private func handleFlip(_ option: FlipOption) -> UIImage {
        return image.flip(horizontal: option.horizontal, vertical: option.vertical)
    }
}
