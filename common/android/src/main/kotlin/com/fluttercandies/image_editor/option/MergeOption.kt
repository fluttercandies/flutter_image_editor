package com.fluttercandies.image_editor.option

class MergeOption(map: Map<*, *>) {
    val formatOption = FormatOption(map["fmt"] as Map<*, *>)
    val images: List<MergeImage>
    val width: Int = map["w"] as Int
    val height: Int = map["h"] as Int

    init {
        val list = ArrayList<MergeImage>()
        val src = map["images"] as List<*>
        for (any in src) {
            if (any is Map<*, *>) {
                list.add(MergeImage(any))
            }
        }
        images = list
    }
}

class MergeImage(map: Map<*, *>) {
    val byteArray: ByteArray = (map["src"] as Map<*, *>)["memory"] as ByteArray
    val position = ImagePosition(map["position"] as Map<*, *>)
}

class ImagePosition(map: Map<*, *>) {
    val x = map["x"] as Int
    val y = map["y"] as Int
    val width = map["w"] as Int
    val height = map["h"] as Int
}
