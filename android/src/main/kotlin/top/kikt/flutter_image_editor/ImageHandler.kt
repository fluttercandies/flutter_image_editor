package top.kikt.flutter_image_editor

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Matrix
import java.io.File
import java.io.FileOutputStream

/// create 2019-10-08 by cai


class ImageHandler(src: String, target: String) {
  
  private val dstFile = File(target)
  
  private var bitmap: Bitmap = BitmapFactory.decodeFile(src)
  
  fun handle(options: List<Option>) {
    for (option in options) {
      when (option) {
        is FlipOption -> bitmap = handleFlip(option)
        is ClipOption -> bitmap = handleClip(option)
        is RotateOption -> bitmap = handleRotate(option)
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
//    val x = (option.width + option.x) / 2
//    val y = (option.height + option.y) / 2
    val x = option.x
    val y = option.y
    return Bitmap.createBitmap(bitmap, x, y, option.width, option.height, null, false)
  }
  
  fun output() {
    val outputStream = FileOutputStream(dstFile)
    outputStream.use {
      bitmap.compress(Bitmap.CompressFormat.PNG, 95, outputStream)
//      bitmap.recycle()
    }
  }
  
}