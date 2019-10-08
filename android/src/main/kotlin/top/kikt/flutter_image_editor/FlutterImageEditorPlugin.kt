package top.kikt.flutter_image_editor

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterImageEditorPlugin : MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "top.kikt/flutter_image_editor")
      channel.setMethodCallHandler(FlutterImageEditorPlugin())
    }
  }
  
  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "handleImage") {
      val src = call.argument<String>("src")!!
      val target = call.argument<String>("target")!!
      val optionMap = call.argument<List<Any>>("options")!!
      val option = ConvertUtils.convertMapOption(optionMap)
      ImageHandler(src, target).handle(option)
    }
  }
}
