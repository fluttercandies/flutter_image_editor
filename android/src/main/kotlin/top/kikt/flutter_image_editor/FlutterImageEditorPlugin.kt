package top.kikt.flutter_image_editor

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.PrintWriter
import java.io.StringWriter

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
      try {
        val src = call.argument<String>("src")!!
        val target = call.argument<String>("target")!!
        val optionMap = call.argument<List<Any>>("options")!!
        val option = ConvertUtils.convertMapOption(optionMap)
        val imageHandler = ImageHandler(src, target)
        imageHandler.handle(option)
        imageHandler.output()
        result.success(target)
      } catch (e: Exception) {
        val writer = StringWriter()
        val printWriter = PrintWriter(writer)
        printWriter.use {
          e.printStackTrace(printWriter)
          result.error(writer.buffer.toString(), "", null)
        }
      }
    }
  }
}
