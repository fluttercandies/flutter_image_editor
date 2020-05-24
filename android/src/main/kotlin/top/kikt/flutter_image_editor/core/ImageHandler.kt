package top.kikt.flutter_image_editor.core

import android.graphics.*
import android.text.TextPaint
import top.kikt.flutter_image_editor.option.*
import java.io.ByteArrayOutputStream
import java.io.FileOutputStream
import java.io.OutputStream
import kotlin.math.min


/// create 2019-10-08 by cai

class ImageHandler(private var bitmap: Bitmap) {

  fun handle(options: List<Option>) {
    for (option in options) {
      when (option) {
        is FlipOption -> bitmap = handleFlip(option)
        is ClipOption -> bitmap = handleClip(option)
        is RotateOption -> bitmap = handleRotate(option)
        is ColorOption -> bitmap = handleColor(option)
        is ScaleOption -> bitmap = handleScale(option)
        is AddTextOpt -> bitmap = handleText(option)
      }
    }
  }

  private fun handleScale(option: ScaleOption): Bitmap {
    val w = min(bitmap.width, option.width)
    val h = min(bitmap.height, option.height)

    val newBitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)

    val canvas = Canvas(newBitmap)

    val p = Paint()

    val m = Matrix()

    val width: Int = bitmap.width
    val height: Int = bitmap.height
    if (width != w || height != h) {
      val sx: Float = w / width.toFloat()
      val sy: Float = h / height.toFloat()
      m.setScale(sx, sy)
    }

    canvas.drawBitmap(bitmap, m, p)

    return newBitmap
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

  private fun handleText(option: AddTextOpt): Bitmap {
    val newBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, bitmap.config)

    val canvas = Canvas(newBitmap)
    val paint = Paint()

    canvas.drawBitmap(bitmap, 0F, 0F, paint)

    for (text in option.texts) {
      val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG)
      textPaint.color = Color.argb(text.a, text.r, text.g, text.b)
      textPaint.textSize = text.fontSizePx.toFloat()
      canvas.drawText(text.text, text.x.toFloat(), text.y.toFloat(), textPaint)
    }

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