//
// Created by Caijinglong on 2019-10-09.
//

import Foundation

struct FlipOption: FlutterImageEditorOption {
  var horizontal: Bool = true
  var vertical: Bool = false
}

struct ClipOption: FlutterImageEditorOption {
  var x: Int = 0
  var y: Int = 0
  var width: Int = 100
  var height: Int = 100
}

struct RotateOption: FlutterImageEditorOption {
  var degree: Int = 0
}
