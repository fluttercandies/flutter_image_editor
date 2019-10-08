package top.kikt.flutter_image_editor

/// create 2019-10-08 by cai


object ConvertUtils {
  
  fun convertMapOption(optionList: List<Any>): List<Option> {
    val list = ArrayList<Option>()
    for (optionMap in optionList) {
      if (optionMap !is Map<*, *>) {
        continue
      }
      
      when (optionMap["type"]) {
        "flip" -> {
          val flipOption = getFlipOption(optionMap["value"])
          list.add(flipOption)
        }
        else -> {
        }
      }
    }
    
    return list
  }
  
  private fun getFlipOption(optionMap: Any?): FlipOption {
    if (optionMap !is Map<*, *>) {
      return FlipOption(0)
    }
    
    return FlipOption(optionMap["type"] as Int)
  }
  
}