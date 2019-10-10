package top.kikt.flutter_image_editor.util

import top.kikt.flutter_image_editor.option.ClipOption
import top.kikt.flutter_image_editor.option.FlipOption
import top.kikt.flutter_image_editor.option.Option
import top.kikt.flutter_image_editor.option.RotateOption

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
        "rotate" -> {
          val rotateOption = getRotateOption(valueMap)
          list.add(rotateOption)
        }
        else -> {
        }
      }
    }
    
    return list
  }
  
  private fun getRotateOption(optionMap: Any?): RotateOption {
    if (optionMap !is Map<*, *>) {
      return RotateOption(0)
    }
    
    return RotateOption(optionMap["angle"] as Int)
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
  
}