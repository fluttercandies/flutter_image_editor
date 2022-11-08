package com.fluttercandies.image_editor.option

import android.graphics.PorterDuff
import com.fluttercandies.image_editor.util.ConvertUtils

class MixImageOpt(map: Map<*, *>) : Option {
    val img: ByteArray = (map["target"] as Map<*, *>)["memory"] as ByteArray
    val x = map["x"] as Int
    val y = map["y"] as Int
    val w = map["w"] as Int
    val h = map["h"] as Int
    private val type = map["mixMode"] as String

    val porterDuffMode: PorterDuff.Mode
        get() = ConvertUtils.convertToPorterDuffMode(type)
}
