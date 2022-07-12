package com.fluttercandies.image_editor.core

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Rect
import com.fluttercandies.image_editor.option.MergeOption
import java.io.ByteArrayOutputStream

class ImageMerger(private val mergeOption: MergeOption) {
    fun process(): ByteArray? {
        val newBitmap = Bitmap.createBitmap(mergeOption.width, mergeOption.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(newBitmap)
        for (mergeImage in mergeOption.images) {
            val bitmap = BitmapFactory.decodeByteArray(mergeImage.byteArray, 0, mergeImage.byteArray.count())
            val position = mergeImage.position
            val dstRect = Rect(
                position.x,
                position.y,
                position.x + position.width,
                position.y + position.height
            )
            canvas.drawBitmap(bitmap, null, dstRect, null)
        }
        val fmt = mergeOption.formatOption
        val stream = ByteArrayOutputStream()
        val format: Bitmap.CompressFormat =
            if (fmt.format == 1) Bitmap.CompressFormat.JPEG else Bitmap.CompressFormat.PNG
        newBitmap.compress(format, fmt.quality, stream)
//    newBitmap.recycle()
        return stream.toByteArray()
    }
}
