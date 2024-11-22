package com.fluttercandies.image_editor.core

import android.graphics.*
import android.os.Build
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import com.fluttercandies.image_editor.common.font.FontUtils
import com.fluttercandies.image_editor.option.*
import com.fluttercandies.image_editor.option.draw.DrawOption
import java.io.ByteArrayOutputStream
import java.io.FileOutputStream
import java.io.OutputStream

class ImageHandler(private var bitmap: Bitmap) {
    fun handle(options: List<Option>) {
        for (option in options) {
            when (option) {
                is ColorOption -> bitmap = handleColor(option)
                is ScaleOption -> bitmap = handleScale(option)
                is FlipOption -> bitmap = handleFlip(option)
                is ClipOption -> bitmap = handleClip(option)
                is RotateOption -> bitmap = handleRotate(option)
                is AddTextOpt -> bitmap = handleText(option)
                is MixImageOpt -> bitmap = handleMixImage(option)
                is DrawOption -> bitmap = bitmap.draw(option)
            }
        }
    }

    private fun handleMixImage(option: MixImageOpt): Bitmap {
        val newBitmap = bitmap.createNewBitmap(bitmap.width, bitmap.height)
        val canvas = Canvas(newBitmap)
        canvas.drawBitmap(bitmap, 0F, 0F, null)
        val src = BitmapFactory.decodeByteArray(option.img, 0, option.img.count())
        val paint = Paint()
        paint.xfermode = PorterDuffXfermode(option.porterDuffMode)
        val dstRect = Rect(option.x, option.y, option.x + option.w, option.y + option.h)
        canvas.drawBitmap(src, null, dstRect, paint)
        return newBitmap
    }

    private fun handleScale(option: ScaleOption): Bitmap {
        var w = option.width
        var h = option.height
        if (option.keepRatio) {
            val srcRatio = bitmap.width.toFloat() / bitmap.height.toFloat()
            if (option.keepWidthFirst) {
                h = (w / srcRatio).toInt()
            } else {
                w = (srcRatio * h).toInt()
            }
        }
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
        val matrix = Matrix().apply {
            //      val rotate = option.angle.toFloat() / 180 * Math.PI
            this.postRotate(option.angle.toFloat())
        }
        val out = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        val canvas = Canvas()
        canvas.drawBitmap(out, matrix, null)
        return out
    }

    private fun handleFlip(option: FlipOption): Bitmap {
        val matrix = Matrix().apply {
            val x = if (option.horizontal) -1F else 1F
            val y = if (option.vertical) -1F else 1F
            postScale(x, y)
        }
        val out = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        val canvas = Canvas()
        canvas.drawBitmap(out, matrix, null)
        return out
    }

    private fun handleClip(option: ClipOption): Bitmap {
        val x = option.x
        val y = option.y
        return Bitmap.createBitmap(bitmap, x, y, option.width, option.height, null, false)
    }

    private fun handleColor(option: ColorOption): Bitmap {
        val newBitmap = bitmap.createNewBitmap(bitmap.width, bitmap.height)
        val canvas = Canvas(newBitmap)
        val paint = Paint()
        paint.colorFilter = ColorMatrixColorFilter(option.matrix)
        canvas.drawBitmap(bitmap, 0F, 0F, paint)
        return newBitmap
    }

    private fun handleText(option: AddTextOpt): Bitmap {
        val newBitmap = bitmap.createNewBitmap(bitmap.width, bitmap.height)
        val canvas = Canvas(newBitmap)
        val paint = Paint()
        canvas.drawBitmap(bitmap, 0F, 0F, paint)
        for (text in option.texts) {
            drawText(text, canvas)
        }
        return newBitmap
    }

    private fun drawText(text: Text, canvas: Canvas) {
        val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG)
        textPaint.color = Color.argb(text.a, text.r, text.g, text.b)
        textPaint.textSize = text.fontSizePx.toFloat()
        if (text.fontName.isNotEmpty()) {
            try {
                val typefaceFromAsset = FontUtils.getFont(text.fontName)
                textPaint.typeface = typefaceFromAsset
            } catch (_: Exception) {
            }
        }
        val staticLayout = getStaticLayout(text, textPaint, canvas.width - text.x)

        canvas.translate(text.x.toFloat(), text.y.toFloat())
//        staticLayout.draw(canvas)

        for (i in 0 until staticLayout.lineCount) {
            val lineText = staticLayout.text.subSequence(
                staticLayout.getLineStart(i),
                staticLayout.getLineEnd(i)
            ).toString()

            val lineWidth = textPaint.measureText(lineText)

            val lineY = text.y + (i + 1) * text.fontSizePx
            val lineX =
                when (text.textAlign) {
                    Paint.Align.CENTER -> {
                        (staticLayout.width - lineWidth) / 2
                    }

                    Paint.Align.RIGHT -> {
                        staticLayout.width - lineWidth
                    }

                    else -> {
                        text.x
                    }
                }

            canvas.drawText(lineText, lineX.toFloat(), lineY.toFloat(), textPaint)
        }

        canvas.translate((-text.x).toFloat(), (-text.y).toFloat())
    }

    @Suppress("DEPRECATION")
    private fun getStaticLayout(text: Text, textPaint: TextPaint, width: Int): StaticLayout {
        return if (Build.VERSION.SDK_INT >= 23) {
            StaticLayout.Builder.obtain(
                text.text, 0, text.text.length, textPaint, width
            ).build()
        } else {
            StaticLayout(
                text.text,
                textPaint,
                width,
                Layout.Alignment.ALIGN_NORMAL,
                1.0F,
                0.0F,
                true
            )
        }
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
