package com.fluttercandies.image_editor.option

import android.graphics.Paint

class AddTextOpt : Option {
    val texts = ArrayList<Text>()

    fun addText(text: Text) {
        texts.add(text)
    }
}

data class Text(
    val text: String,
    val x: Int,
    val y: Int,
    val fontSizePx: Int,
    val r: Int,
    val g: Int,
    val b: Int,
    val a: Int,
    val fontName: String,
    val textAlign: Paint.Align
)