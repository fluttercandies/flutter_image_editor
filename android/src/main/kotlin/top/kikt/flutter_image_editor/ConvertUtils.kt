package top.kikt.flutter_image_editor

/// create 2019-10-08 by cai


object ConvertUtils {
  
  fun convertMapOption(optionList: List<Any>): List<Option> {
    val list = ArrayList<Option>()
    for (optionMap in optionList) {
      if (optionMap !is Map<*, *>) {
        continue
      }
  
      val valueMap = optionMap["value"]
      when (optionMap["type"]) {
        "flip" -> {
          val flipOption = getFlipOption(valueMap)
          list.add(flipOption)
        }
        "clip" -> {
          val clipOption = getClipOption(valueMap)
          list.add(clipOption)
        }
        else -> {
        }
      }
    }
    
    return list
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
      return FlipOption(0)
    }
    
    return FlipOption(optionMap["type"] as Int)
  }
  
}