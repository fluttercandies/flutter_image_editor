package com.fluttercandies.image_editor

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import androidx.exifinterface.media.ExifInterface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.fluttercandies.image_editor.common.font.FontUtils
import com.fluttercandies.image_editor.core.BitmapWrapper
import com.fluttercandies.image_editor.core.ImageHandler
import com.fluttercandies.image_editor.core.ImageMerger
import com.fluttercandies.image_editor.core.ResultHandler
import com.fluttercandies.image_editor.error.BitmapDecodeException
import com.fluttercandies.image_editor.option.FlipOption
import com.fluttercandies.image_editor.option.FormatOption
import com.fluttercandies.image_editor.option.MergeOption
import com.fluttercandies.image_editor.option.Option
import com.fluttercandies.image_editor.util.ConvertUtils
import java.io.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class ImageEditorPlugin : FlutterPlugin, MethodCallHandler {
    private var applicationContext: Context? = null

    companion object {
        private const val channelName = "com.fluttercandies/image_editor"

        val threadPool: ExecutorService = Executors.newCachedThreadPool()

        inline fun runOnBackground(crossinline block: () -> Unit) {
            threadPool.execute {
                block()
            }
        }
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        val methodChannel = MethodChannel(binding.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val resultHandler = ResultHandler(result)
        runOnBackground {
            try {
                when (call.method) {
                    "memoryToFile" -> {
                        handle(call, resultHandler, false)
                    }
                    "memoryToMemory" -> {
                        handle(call, resultHandler, true)
                    }
                    "fileToMemory" -> {
                        handle(call, resultHandler, true)
                    }
                    "fileToFile" -> {
                        handle(call, resultHandler, false)
                    }
                    "getCachePath" -> {
                        resultHandler.reply(applicationContext?.cacheDir?.absolutePath)
                    }
                    "mergeToMemory" -> {
                        handleMerge(call, resultHandler, true)
                    }
                    "mergeToFile" -> {
                        handleMerge(call, resultHandler, false)
                    }
                    "registerFont" -> {
                        val fontPath = call.argument<String>("path")!!
                        val name = FontUtils.registerFont(fontPath)
                        resultHandler.reply(name)
                    }
                    else -> {
                        resultHandler.notImplemented()
                    }
                }
            } catch (e: BitmapDecodeException) {
                resultHandler.replyError("Decode bitmap error.")
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

    private fun handleMerge(call: MethodCall, resultHandler: ResultHandler, memory: Boolean) {
        val mergeOptionMap = call.argument<Any>("option") as Map<*, *>
        val mergeOption = MergeOption(mergeOptionMap)
        val imageMerger = ImageMerger(mergeOption)
        val byteArray = imageMerger.process()
        if (byteArray == null) {
            resultHandler.replyError("Cannot merge image.")
            return
        }
        if (memory) {
            resultHandler.reply(byteArray)
        } else {
            val extName = if (mergeOption.formatOption.format == 1) "jpg" else "png"
            val f = File(applicationContext!!.cacheDir, "${System.currentTimeMillis()}.$extName")
            f.writeBytes(byteArray)
            resultHandler.reply(f.path)
        }
    }

    private fun MethodCall.getSrc(): String? {
        return argument<String>("src")
    }

    private fun MethodCall.getTarget(): String? {
        return argument<String>("target")
    }

    private fun MethodCall.getOptions(bitmapWrapper: BitmapWrapper): List<Option> {
        val optionMap = argument<List<Any>>("options")!!
        return ConvertUtils.convertMapOption(optionMap, bitmapWrapper)
    }

    private fun MethodCall.getMemory(): ByteArray? {
        return argument<ByteArray>("image")
    }

    private fun MethodCall.getBitmap(): BitmapWrapper {
        val src = getSrc()
        if (src != null) {
            val bitmap = BitmapFactory.decodeFile(src)
            val exifInterface = ExifInterface(src)
            return wrapperBitmapWrapper(bitmap, exifInterface)
        }
        val memory = getMemory()
        if (memory != null) {
            val bitmap = BitmapFactory.decodeByteArray(memory, 0, memory.count())
            val exifInterface = ExifInterface(ByteArrayInputStream(memory))
            return wrapperBitmapWrapper(bitmap, exifInterface)
        }

        throw BitmapDecodeException()
    }

    private fun wrapperBitmapWrapper(bitmap: Bitmap, exifInterface: ExifInterface): BitmapWrapper {
        var degree = 0
        var flipOption = FlipOption(horizontal = false)

        when (exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)) {
            ExifInterface.ORIENTATION_NORMAL -> {
                degree = 0
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> {
                degree = 90
            }
            ExifInterface.ORIENTATION_ROTATE_180 -> {
                degree = 180
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> {
                degree = 270
            }
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> {
                flipOption = FlipOption(horizontal = true)
            }
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
                flipOption = FlipOption(vertical = true)
            }
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                degree = 90
                flipOption = FlipOption(horizontal = true)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                degree = 270
                flipOption = FlipOption(horizontal = true)
            }
        }
        return BitmapWrapper(bitmap, degree, flipOption)

    }

    private fun MethodCall.getFormatOption(): FormatOption {
        return ConvertUtils.getFormatOption(this)
    }

    private fun handle(
        imageHandler: ImageHandler,
        formatOption: FormatOption,
        outputMemory: Boolean,
        resultHandler: ResultHandler,
        targetPath: String? = null
    ) {
        if (outputMemory) {
            val byteArray = imageHandler.outputByteArray(formatOption)
            resultHandler.reply(byteArray)
        } else {
            if (targetPath == null) {
                resultHandler.reply(null)
            } else {
                imageHandler.outputToFile(targetPath, formatOption)
                resultHandler.reply(targetPath)
            }
        }
    }

    private fun handle(call: MethodCall, resultHandler: ResultHandler, outputMemory: Boolean) {
        val bitmapWrapper = call.getBitmap()
        val imageHandler = ImageHandler(bitmapWrapper.bitmap)
        imageHandler.handle(call.getOptions(bitmapWrapper))
        handle(imageHandler, call.getFormatOption(), outputMemory, resultHandler, call.getTarget())
    }
}
