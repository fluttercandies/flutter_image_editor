import Flutter
import UIKit

public class SwiftFlutterImageEditorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "top.kikt/flutter_image_editor", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterImageEditorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "handleImage" {
      let args = call.arguments as! [String: Any]
      let src = args["src"] as! String
      let target = args["target"] as! String
      let optionMap = args["options"] as! [Any]
      let options = ConvertUtils.getOptions(options: optionMap)

      let handler = UIImageHandler(src: src, target: target)
      handler.handleImage(options: options)
      handler.output()
      result(target)

    } else if call.method == "getCachePath" {
      result(NSTemporaryDirectory())
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}