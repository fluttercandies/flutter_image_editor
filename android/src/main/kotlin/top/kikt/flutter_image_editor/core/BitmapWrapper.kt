package top.kikt.flutter_image_editor.core

import android.graphics.Bitmap
import top.kikt.flutter_image_editor.option.FlipOption

data class BitmapWrapper(val bitmap: Bitmap, val degree: Int, val flipOption: FlipOption)
