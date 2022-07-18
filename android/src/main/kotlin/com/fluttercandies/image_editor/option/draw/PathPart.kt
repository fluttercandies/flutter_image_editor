package com.fluttercandies.image_editor.option.draw

class PathDrawPart(map: Map<*, *>) : DrawPart(map), IHavePaint {
    val autoClose: Boolean
        get() = map["autoClose"] as Boolean
    val paths: List<PathPart>

    init {
        val list = ArrayList<PathPart>()
        val partList = map["parts"] as List<*>
        for (partMap in partList) {
            if (partMap is Map<*, *>) {
                val key = partMap["key"]
                val value = partMap["value"] as Map<*, *>
                val part = when (key) {
                    "move" -> MovePathPart(value)
                    "lineTo" -> LineToPathPart(value)
                    "bezier" -> BezierPathPart(value)
                    "arcTo" -> ArcToPathPart(value)
                    else -> null
                }
                if (part != null) {
                    list.add(part)
                }
            }
        }
        paths = list
    }
}

abstract class PathPart(map: Map<*, *>) : TransferValue(map)

class MovePathPart(map: Map<*, *>) : PathPart(map) {
    val offset = getOffset("offset")
}

class LineToPathPart(map: Map<*, *>) : PathPart(map) {
    val offset = getOffset("offset")
}

class BezierPathPart(map: Map<*, *>) : PathPart(map) {
    val kind = map["kind"] as Int
    val target = getOffset("target")
    val control1 = getOffset("c1")
    val control2 = if (kind == 3) getOffset("c2") else null
}

class ArcToPathPart(map: Map<*, *>) : PathPart(map) {
    val rect = getRect("rect")
    val start = map["start"] as Number
    val sweep = map["sweep"] as Number
    val useCenter = map["useCenter"] as Boolean
}
