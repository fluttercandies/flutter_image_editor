package top.kikt.flutter_image_editor.option.draw

import android.graphics.Color
import android.graphics.Paint
import android.graphics.Point
import android.graphics.Rect

interface ITransferValue {

  val map: Map<*, *>

  fun getColor(key: String = "color"): Int {
    val colorMap = map["color"] as Map<*, *>
    val r = colorMap["r"] as Int
    val g = colorMap["g"] as Int
    val b = colorMap["b"] as Int
    val a = colorMap["a"] as Int
    return Color.argb(a, r, g, b)
  }

  fun getOffset(key: String): Point {
    val offsetMap = map[key] as Map<*, *>
    return convertMapToOffset(offsetMap)
  }

  fun convertMapToOffset(map: Map<*, *>): Point {
    val x = map["x"] as Int
    val y = map["y"] as Int
    return Point(x, y)
  }

  fun getRect(key: String): Rect {
    val offsetMap = map[key] as Map<*, *>

    val l = offsetMap["left"] as Int
    val t = offsetMap["top"] as Int
    val r = l + offsetMap["width"] as Int
    val b = t + offsetMap["height"] as Int

    return Rect(l, t, r, b)
  }
}

abstract class TransferValue(override val map: Map<*, *>) : ITransferValue

class DrawOption(map: Map<*, *>) : TransferValue(map) {


}


interface IHavePaint : ITransferValue {

  fun getPaint(): Paint {
    return DrawPaint(map["paint"] as Map<*, *>).getPaint()
  }

}
