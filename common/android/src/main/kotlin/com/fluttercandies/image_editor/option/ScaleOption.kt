package com.fluttercandies.image_editor.option

data class ScaleOption(val width: Int, val height: Int, val keepRatio: Boolean, val keepWidthFirst: Boolean) : Option
