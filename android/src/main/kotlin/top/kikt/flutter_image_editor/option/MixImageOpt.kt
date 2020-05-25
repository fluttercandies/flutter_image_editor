package top.kikt.flutter_image_editor.option

class MixImageOpt(map: Map<*, *>) : Option {

  val img: ByteArray = (map["target"] as Map<*, *>)["memory"] as ByteArray

  val x = map["x"] as Int
  val y = map["y"] as Int
  val w = map["w"] as Int
  val h = map["h"] as Int

}