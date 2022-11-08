package com.fluttercandies.image_editor.core

import android.graphics.Bitmap
import com.fluttercandies.image_editor.option.FlipOption

data class BitmapWrapper(val bitmap: Bitmap, val degree: Int, val flipOption: FlipOption)
