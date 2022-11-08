package com.fluttercandies.image_editor.option

data class ColorOption(val matrix: FloatArray) : Option {
    companion object {
        val src = ColorOption(
            floatArrayOf(
                1F, 0F, 0F, 0F, 0F,
                0F, 1F, 0F, 0F, 0F,
                0F, 0F, 1F, 0F, 0F,
                0F, 0F, 0F, 1F, 0F
            )
        )
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        other as ColorOption
        if (!matrix.contentEquals(other.matrix)) return false
        return true
    }

    override fun hashCode(): Int {
        return matrix.contentHashCode()
    }
}
