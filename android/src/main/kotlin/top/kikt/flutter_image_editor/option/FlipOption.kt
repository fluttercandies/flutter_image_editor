package top.kikt.flutter_image_editor.option

/// create 2019-10-08 by cai


data class FlipOption(val horizontal: Boolean = false, val vertical: Boolean = false) : Option {
  fun canIgnore(): Boolean {
    return !horizontal || !vertical
  }
}