package top.kikt.flutter_image_editor.option

/// create 2019-10-14 by cai


class FormatOption(fmtMap:Map<*,*>) {
  val format = fmtMap["format"] as Int
  val quality: Int = fmtMap["quality"] as Int
}