package com.fluttercandies.image_editor.option

data class RotateOption(val angle: Int) : Option {
    override fun canIgnore(): Boolean = angle % 360 == 0
}
