package top.kikt.flutter_image_editor

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import top.kikt.flutter_image_editor.core.ImageHandler
import top.kikt.flutter_image_editor.core.ResultHandler
import top.kikt.flutter_image_editor.util.ConvertUtils
import java.io.PrintWriter
import java.io.StringWriter
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class FlutterImageEditorPlugin(private val registrar: Registrar) : MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "top.kikt/flutter_image_editor")
      channel.setMethodCallHandler(FlutterImageEditorPlugin(registrar))
    }
    
    val threadPool: ExecutorService = Executors.newCachedThreadPool()
    
    inline fun runOnBackground(crossinline block: () -> Unit) {
      threadPool.execute {
        block()
      }
    }
  }
  
  override fun onMethodCall(call: MethodCall, result: Result) {
    val resultHandler = ResultHandler(result)
    runOnBackground {
      when (call.method) {
        "handleImage" -> {
          try {
            val src = call.argument<String>("src")!!
            val target = call.argument<String>("target")!!
            val optionMap = call.argument<List<Any>>("options")!!
            val option = ConvertUtils.convertMapOption(optionMap)
            val imageHandler = ImageHandler(src, target)
            imageHandler.handle(option)
            imageHandler.output()
            resultHandler.reply(target)
          } catch (e: Exception) {
            val writer = StringWriter()
            val printWriter = PrintWriter(writer)
            printWriter.use {
              e.printStackTrace(printWriter)
              resultHandler.replyError(writer.buffer.toString(), "", null)
              
            }
          }
        }
        "getCachePath" -> {
          val cachePath = registrar.activeContext().cacheDir.absolutePath
          resultHandler.reply(cachePath)
        }
        else -> {
          resultHandler.notImplemented()
        }
      }
    }
  }
}
