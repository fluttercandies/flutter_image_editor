import Flutter
import UIKit

public class SwiftFlutterImageEditorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "top.kikt/flutter_image_editor", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterImageEditorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCachePath":
            result(NSTemporaryDirectory())
        case "memoryToFile":
            handleResult(call: call, outputMemory: false, result: result)
        case "memoryToMemory":
            handleResult(call: call, outputMemory: true, result: result)
        case "fileToMemory":
            handleResult(call: call, outputMemory: true, result: result)
        case "fileToFile":
            handleResult(call: call, outputMemory: false, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func handleResult(call: FlutterMethodCall, outputMemory: Bool, result: @escaping FlutterResult) {
        guard let image = call.getUIImage() else {
            result(FlutterError(code: "decode image error", message: nil, details: nil))
            return
        }

        let args = call.arguments as! [String: Any]
        let imageHandler = UIImageHandler(image: image)

        let optionMap = args["options"] as! [Any]
        let options = ConvertUtils.getOptions(options: optionMap)
        imageHandler.handleImage(options: options)

        if outputMemory {
            result(imageHandler.outputMemory())
        } else {
            let target = args["target"] as! String
            imageHandler.outputFile(targetPath: target)
            result(target)
        }
    }
}

extension FlutterMethodCall {
    func getUIImage() -> UIImage? {
        let args = arguments as! [String: Any]

        let src = args["src"] as? String

        if src != nil {
            let url = URL(fileURLWithPath: src!)
            return UIImage(contentsOfFile: url.absoluteString)
        }

        guard let data = args["image"] as? FlutterStandardTypedData else {
            return nil
        }

        let image = data.data

        return UIImage(data: image)
    }
}