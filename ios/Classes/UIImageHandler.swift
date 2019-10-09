//
// Created by Caijinglong on 2019-10-09.
//

import Foundation
import UIKit

class UIImageHandler {
  var src: String
  var target: String

  var image: UIImage

  init(src: String, target: String) {
    self.src = src
    self.target = target

    let data = try! Data(contentsOf: URL(fileURLWithPath: src), options: .mappedRead)

    image = UIImage(data: data)!
  }

  func handleImage(options: [FlutterImageEditorOption]) {
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

  func output() {
    let data = UIImagePNGRepresentation(image)
    try! data?.write(to: URL(fileURLWithPath: target))
  }

  private func handleRotate(_ option: RotateOption) -> UIImage {
    return image.rotate(option.angle)
  }

  private func handleClip(_ option: ClipOption) -> UIImage {
    return image.crop(x: option.x, y: option.y, width: option.width, height: option.height)
  }

  private func handleFlip(_ option: FlipOption) -> UIImage {
    return image.flip(horizontal: option.horizontal, vertical: option.vertical)
  }
}
