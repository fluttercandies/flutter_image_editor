package com.fluttercandies.image_editor.option

class FormatOption(fmtMap: Map<*, *>) {
    val format = fmtMap["format"] as Int
    val quality: Int = fmtMap["quality"] as Int
}
