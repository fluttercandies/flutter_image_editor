package top.kikt.flutter_image_editor

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import top.kikt.flutter_image_editor.core.ImageHandler
import top.kikt.flutter_image_editor.core.ResultHandler
import top.kikt.flutter_image_editor.error.BitmapDecodeException
import top.kikt.flutter_image_editor.option.Option
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
      try {
        when (call.method) {
          "memoryToFile" -> {
            val imageHandler = ImageHandler(call.getBitmap())
            imageHandler.handle(call.getOptions())
            handle(imageHandler, false, resultHandler, call.getTarget())
          }
          "memoryToMemory" -> {
            val imageHandler = ImageHandler(call.getBitmap())
            imageHandler.handle(call.getOptions())
            handle(imageHandler, true, resultHandler)
          }
          "fileToMemory" -> {
            val imageHandler = ImageHandler(call.getBitmap())
            imageHandler.handle(call.getOptions())
            handle(imageHandler, true, resultHandler)
          }
          "fileToFile" -> {
            val imageHandler = ImageHandler(call.getBitmap())
            imageHandler.handle(call.getOptions())
            handle(imageHandler, false, resultHandler, call.getTarget())
          }
          "getCachePath" -> {
            val cachePath = registrar.activeContext().cacheDir.absolutePath
            resultHandler.reply(cachePath)
          }
          else -> {
            resultHandler.notImplemented()
          }
        }
      } catch (e: BitmapDecodeException) {
        resultHandler.replyError("decode bitmap error")
      } catch (e: Exception) {
        val writer = StringWriter()
        val printWriter = PrintWriter(writer)
        printWriter.use {
          e.printStackTrace(printWriter)
          resultHandler.replyError(writer.buffer.toString(), "", null)
          
        }
      }
    }
  }
  
  private fun MethodCall.getSrc(): String? {
    return this.argument<String>("src")
  }
  
  private fun MethodCall.getTarget(): String {
    return this.argument<String>("target")!!
  }
  
  fun MethodCall.getOptions(): List<Option> {
    val optionMap = this.argument<List<Any>>("options")!!
    return ConvertUtils.convertMapOption(optionMap)
  }
  
  private fun MethodCall.getMemory(): ByteArray? {
    return this.argument<ByteArray>("image")
  }
  
  private fun MethodCall.getBitmap(): Bitmap {
    if (getSrc() != null) {
      return BitmapFactory.decodeFile(getSrc())
    }
    
    val memory = getMemory()
    if (memory != null) {
      return BitmapFactory.decodeByteArray(memory, 0, memory.count())
    }
    
    throw BitmapDecodeException()
  }
  
  private fun handle(imageHandler: ImageHandler, outputMemory: Boolean, resultHandler: ResultHandler, targetPath: String? = null) {
    if (outputMemory) {
      val byteArray = imageHandler.outputByteArray()
      resultHandler.reply(byteArray)
    } else {
      if (targetPath == null) {
        resultHandler.reply(null)
      } else {
        imageHandler.outputToFile(targetPath)
        resultHandler.reply(targetPath)
      }
    }
  }
}
