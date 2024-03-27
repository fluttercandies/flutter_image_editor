package com.fluttercandies.image_editor.util

import android.graphics.Paint
import android.graphics.PorterDuff
import io.flutter.plugin.common.MethodCall
import com.fluttercandies.image_editor.core.BitmapWrapper
import com.fluttercandies.image_editor.option.*
import com.fluttercandies.image_editor.option.draw.DrawOption

object ConvertUtils {
    fun getFormatOption(call: MethodCall): FormatOption {
        val fmtMap = call.argument<Map<*, *>>("fmt")!!
        return FormatOption(fmtMap)
    }

    fun convertMapOption(optionList: List<Any>, bitmapWrapper: BitmapWrapper): List<Option> {
        val list = ArrayList<Option>()
        if (bitmapWrapper.degree != 0) {
            list.add(RotateOption(bitmapWrapper.degree))
        }
        if (!bitmapWrapper.flipOption.canIgnore()) {
            list.add(bitmapWrapper.flipOption)
        }
        loop@ for (optionMap in optionList) {
            if (optionMap !is Map<*, *>) {
                continue
            }
            val valueMap = optionMap["value"]
            if (valueMap !is Map<*, *>) {
                continue@loop
            }
            when (optionMap["type"]) {
                "flip" -> {
                    val flipOption = getFlipOption(valueMap)
                    list.add(flipOption)
                }

                "clip" -> {
                    val clipOption = getClipOption(valueMap)
                    list.add(clipOption)
                }

                "rotate" -> {
                    val rotateOption = getRotateOption(valueMap)
                    list.add(rotateOption)
                }

                "color" -> {
                    val colorOption: ColorOption = getColorOption(valueMap)
                    list.add(colorOption)
                }

                "scale" -> {
                    val scaleOption: ScaleOption = getScaleOption(valueMap) ?: continue@loop
                    list.add(scaleOption)
                }

                "add_text" -> {
                    val addTextOption: AddTextOpt = getTextOption(valueMap) ?: continue@loop
                    list.add(addTextOption)
                }

                "mix_image" -> {
                    val mixImageOpt = MixImageOpt(valueMap)
                    list.add(mixImageOpt)
                }

                "draw" -> {
                    val drawOption = DrawOption(valueMap)
                    list.add(drawOption)
                }
            }
        }
        return list
    }

    private fun getTextOption(valueMap: Any?): AddTextOpt? {
        if (valueMap !is Map<*, *>) {
            return null
        }
        val list: List<*> = valueMap["texts"]!!.asValue()
        if (list.isEmpty()) {
            return null
        }
        val addTextOpt = AddTextOpt()
        for (v in list) {
            if (v is Map<*, *>) {
                addTextOpt.addText(convertToText(v))
            }
        }
        return addTextOpt
    }

    private fun convertToText(v: Map<*, *>): Text {
        return Text(
            v["text"]!!.asValue(),
            v["x"]!!.asValue(),
            v["y"]!!.asValue(),
            v["size"]!!.asValue(),
            v["r"]!!.asValue(),
            v["g"]!!.asValue(),
            v["b"]!!.asValue(),
            v["a"]!!.asValue(),
            v["fontName"]!!.asValue(),
            v["textAlign"]!!.toTextAlign()
        )
    }

    private fun getScaleOption(optionMap: Any?): ScaleOption? {
        if (optionMap !is Map<*, *>) {
            return null
        }
        val w = optionMap["width"] as Int
        val h = optionMap["height"] as Int
        val keepRatio = optionMap["keepRatio"] as Boolean
        val keepWidthFirst = optionMap["keepWidthFirst"] as Boolean
        return ScaleOption(w, h, keepRatio, keepWidthFirst)
    }

    private fun getColorOption(optionMap: Any?): ColorOption {
        if (optionMap !is Map<*, *>) {
            return ColorOption.src
        }
        val matrix = (optionMap["matrix"] as List<*>).map {
            if (it is Double) it.toFloat() else 0F
        }.toFloatArray()
        return ColorOption(matrix)
    }

    private fun getRotateOption(optionMap: Any?): RotateOption {
        if (optionMap !is Map<*, *>) {
            return RotateOption(0)
        }
        return RotateOption(optionMap["degree"] as Int)
    }

    private fun getClipOption(optionMap: Any?): ClipOption {
        if (optionMap !is Map<*, *>) {
            return ClipOption(0, 0, -1, -1)
        }
        val width = (optionMap["width"] as Number).toInt()
        val height = (optionMap["height"] as Number).toInt()
        val x = (optionMap["x"] as Number).toInt()
        val y = (optionMap["y"] as Number).toInt()

        return ClipOption(x, y, width, height)
    }

    private fun getFlipOption(optionMap: Any?): FlipOption {
        if (optionMap !is Map<*, *>) {
            return FlipOption()
        }
        return FlipOption(optionMap["h"] as Boolean, optionMap["v"] as Boolean)
    }

    fun convertToPorterDuffMode(type: String): PorterDuff.Mode {
        return when (type) {
            "clear" -> PorterDuff.Mode.CLEAR
            "src" -> PorterDuff.Mode.SRC
            "dst" -> PorterDuff.Mode.DST
            "srcOver" -> PorterDuff.Mode.SRC_OVER
            "dstOver" -> PorterDuff.Mode.DST_OVER
            "srcIn" -> PorterDuff.Mode.SRC_IN
            "dstIn" -> PorterDuff.Mode.DST_IN
            "srcOut" -> PorterDuff.Mode.SRC_OUT
            "dstOut" -> PorterDuff.Mode.DST_OUT
            "srcATop" -> PorterDuff.Mode.SRC_ATOP
            "dstATop" -> PorterDuff.Mode.DST_ATOP
            "xor" -> PorterDuff.Mode.XOR
            "darken" -> PorterDuff.Mode.DARKEN
            "lighten" -> PorterDuff.Mode.LIGHTEN
            "multiply" -> PorterDuff.Mode.MULTIPLY
            "screen" -> PorterDuff.Mode.SCREEN
            "overlay" -> PorterDuff.Mode.OVERLAY
            else -> PorterDuff.Mode.SRC_OVER
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> Any.asValue(): T {
        return this as T
    }
}

private fun Any.toTextAlign(): Paint.Align {
    return when (this) {
        "left" -> Paint.Align.LEFT
        "center" -> Paint.Align.CENTER
        "right" -> Paint.Align.RIGHT
        else -> Paint.Align.LEFT
    }
}
