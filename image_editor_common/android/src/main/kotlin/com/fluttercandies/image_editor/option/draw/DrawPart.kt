package com.fluttercandies.image_editor.option.draw

import android.graphics.Paint
import android.graphics.Point
import android.graphics.Rect

abstract class DrawPart(map: Map<*, *>) : TransferValue(map)

class DrawPaint(map: Map<*, *>) : TransferValue(map) {
    fun getPaint(): Paint {
        return Paint().apply {
            color = this@DrawPaint.getColor("color")
            strokeWidth = (map["lineWeight"] as Number).toFloat()
            style = if (map["paintStyleFill"] as Boolean) Paint.Style.FILL else Paint.Style.STROKE
        }
    }
}

class LineDrawPart(map: Map<*, *>) : DrawPart(map), IHavePaint {
    val start = getOffset("start")
    val end = getOffset("end")
}

class PointsDrawPart(map: Map<*, *>) : DrawPart(map), IHavePaint {
    val offsets: List<Point>
        get() {
            val list = ArrayList<Point>()
            for (child in (map["offset"] as List<*>)) {
                if (child is Map<*, *>) {
                    val offset = convertMapToOffset(child)
                    list.add(offset)
                }
            }
            return list
        }
//    val mode: Int = map["mode"] as Int
}

class RectDrawPart(map: Map<*, *>) : DrawPart(map), IHavePaint {
    val rect: Rect = getRect("rect")
}

class OvalDrawPart(map: Map<*, *>) : DrawPart(map), IHavePaint {
    val rect: Rect = getRect("rect")
}
