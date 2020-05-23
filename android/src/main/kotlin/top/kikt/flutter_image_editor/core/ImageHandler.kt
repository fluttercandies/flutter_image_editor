package top.kikt.flutter_image_editor.core

import android.graphics.*
import top.kikt.flutter_image_editor.option.*
import java.io.ByteArrayOutputStream
import java.io.FileOutputStream
import java.io.OutputStream


/// create 2019-10-08 by cai

class ImageHandler(private var bitmap: Bitmap) {

  fun handle(options: List<Option>) {
    for (option in options) {
      when (option) {
        is FlipOption -> bitmap = handleFlip(option)
        is ClipOption -> bitmap = handleClip(option)
        is RotateOption -> bitmap = handleRotate(option)
        is ColorOption -> bitmap = handleColor(option)
      }
    }
  }

  private fun handleRotate(option: RotateOption): Bitmap {
    val tmpBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(tmpBitmap)
    val matrix = Matrix().apply {
      //      val rotate = option.angle.toFloat() / 180 * Math.PI
      this.postRotate(option.angle.toFloat())
    }

    val out = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    canvas.drawBitmap(out, matrix, null)
    return out
  }

  private fun handleFlip(option: FlipOption): Bitmap {
    val tmpBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(tmpBitmap)
    val matrix = Matrix().apply {
      val x = if (option.horizontal) -1F else 1F
      val y = if (option.vertical) -1F else 1F
      postScale(x, y)
    }

    val out = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    canvas.drawBitmap(out, matrix, null)
    return out
  }

  private fun handleClip(option: ClipOption): Bitmap {
    val x = option.x
    val y = option.y
    return Bitmap.createBitmap(bitmap, x, y, option.width, option.height, null, false)
  }

  private fun handleColor(option: ColorOption): Bitmap {
    val newBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, bitmap.config)

    val canvas = Canvas(newBitmap)

    val paint = Paint()
    paint.colorFilter = ColorMatrixColorFilter(option.matrix)

    canvas.drawBitmap(bitmap, 0F, 0F, paint)

    return newBitmap
  }

  fun outputToFile(dstPath: String, formatOption: FormatOption) {
    val outputStream = FileOutputStream(dstPath)
    output(outputStream, formatOption)
  }

  fun outputByteArray(formatOption: FormatOption): ByteArray {
    val outputStream = ByteArrayOutputStream()
    output(outputStream, formatOption)
    return outputStream.toByteArray()
  }

  private fun output(outputStream: OutputStream, formatOption: FormatOption) {
    outputStream.use {
      if (formatOption.format == 0) {
        bitmap.compress(Bitmap.CompressFormat.PNG, formatOption.quality, outputStream)
      } else {
        bitmap.compress(Bitmap.CompressFormat.JPEG, formatOption.quality, outputStream)
      }
    }
  }
}