//
// Created by Caijinglong on 2019-10-09.
//

import Foundation

class ConvertUtils {
  static func getOptions(options: [Any]) -> [FlutterImageEditorOption] {
    var array = [FlutterImageEditorOption]()

    for opt in options {
      guard opt is [String: Any] else {
        continue
      }

      let dictionary = opt as! [String: Any]

      let valueMap = dictionary["value"] as! [String: Any]
      let type = dictionary["type"] as! String
      switch type {
      case "flip":
        let flipOption: FlutterImageEditorOption = getFlipOption(valueMap)
        array.append(flipOption)

      case "clip":
        let flipOption: FlutterImageEditorOption = getClipOption(valueMap)
        array.append(flipOption)

      case "rotate":
        let flipOption: FlutterImageEditorOption = getRotateOption(valueMap)
        array.append(flipOption)
      default: continue
      }
    }

    return array
  }

  private class func getRotateOption(_ map: [String: Any]) -> FlutterImageEditorOption {
    return RotateOption(angle: map["angle"] as! Int)
  }

  private class func getClipOption(_ map: [String: Any]) -> FlutterImageEditorOption {
    let x = map["x"] as! Int
    let y = map["y"] as! Int
    let width = map["width"] as! Int
    let height = map["height"] as! Int
    return ClipOption(x: x, y: y, width: width, height: height)
  }

  private class func getFlipOption(_ map: [String: Any]) -> FlutterImageEditorOption {
    let h = map["h"] as! Bool
    let v = map["v"] as! Bool
    return FlipOption(horizontal: h, vertical: v)
  }
}