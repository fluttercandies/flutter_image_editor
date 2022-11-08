package com.fluttercandies.image_editor.option

data class FlipOption(val horizontal: Boolean = false, val vertical: Boolean = false) : Option {
    override fun canIgnore(): Boolean = !horizontal || !vertical
}
