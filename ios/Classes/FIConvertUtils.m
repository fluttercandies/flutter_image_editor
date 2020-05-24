//
// Created by cjl on 2020/5/21.
//

#import "FIConvertUtils.h"

@implementation FIConvertUtils {
}
+ (FIEditorOptionGroup *)getOptions:(NSArray<NSDictionary *> *)dict {
  FIEditorOptionGroup *group = [FIEditorOptionGroup new];
  NSMutableArray *optionArray = [NSMutableArray new];
  group.options = optionArray;
  for (NSDictionary *map in dict) {
    NSString *type = (NSString *)map[@"type"];
    NSDictionary *value = map[@"value"];
    NSObject<FIOption> *option;
    if ([@"flip" isEqualToString:type]) {
      option = [FIFlipOption createFromDict:value];
    } else if ([@"clip" isEqualToString:type]) {
      option = [FIClipOption createFromDict:value];
    } else if ([@"rotate" isEqualToString:type]) {
      option = [FIRotateOption createFromDict:value];
    } else if ([@"color" isEqualToString:type]) {
      option = [FIColorOption createFromDict:value];
    } else if ([@"scale" isEqualToString:type]) {
      option = [FIScaleOption createFromDict:value];
    } else if ([@"add_text" isEqualToString:type]) {
      option = [FIAddTextOption createFromDict:value];
    }
    if (option) {
      [optionArray addObject:option];
    }
  }
  return group;
}

@end

@implementation FIFlipOption {
}
+ (id)createFromDict:(NSDictionary *)dict {
  FIFlipOption *option = [FIFlipOption new];
  option.horizontal = [dict[@"h"] boolValue];
  option.vertical = [dict[@"v"] boolValue];
  return option;
}

@end

@implementation FIClipOption {
}
+ (id)createFromDict:(NSDictionary *)dict {
  FIClipOption *option = [FIClipOption new];
  option.x = [dict[@"x"] intValue];
  option.y = [dict[@"y"] intValue];
  option.width = [dict[@"width"] intValue];
  option.height = [dict[@"height"] intValue];
  return option;
}

@end

@implementation FIRotateOption {
}
+ (id)createFromDict:(NSDictionary *)dict {
  FIRotateOption *option = [FIRotateOption new];
  option.degree = [dict[@"degree"] intValue];
  return option;
}

@end

@implementation FIFormatOption {
}
+ (id)createFromDict:(NSDictionary *)dict {
  FIFormatOption *option = [FIFormatOption new];
  option.format = [dict[@"format"] intValue];
  option.quality = [dict[@"quality"] intValue];
  return option;
}

@end

@implementation FIColorOption

+ (id)createFromDict:(NSDictionary *)dict {
  NSArray *array = dict[@"matrix"];
  FIColorOption *option = [FIColorOption new];
  option.matrix = array;
  return option;
}

@end

@implementation FIScaleOption
+ (id)createFromDict:(NSDictionary *)dict {
  FIScaleOption *option = [FIScaleOption new];
  option.width = [dict[@"width"] intValue];
  option.height = [dict[@"height"] intValue];
  return option;
}

@end

@implementation FIAddText
+(id)createFromDict:(NSDictionary *)dict{
    FIAddText *text = [FIAddText new];
    
    text.text = dict[@"text"];
    text.fontSizePx = [dict[@"size"] intValue];
    
    text.x = [dict[@"x"] intValue];
    text.y = [dict[@"y"] intValue];
    
    text.r = [dict[@"r"] intValue];
    text.g = [dict[@"g"] intValue];
    text.b = [dict[@"b"] intValue];
    text.a = [dict[@"a"] intValue];
    
    return text;
}
@end

@implementation FIAddTextOption

+(id)createFromDict:(NSDictionary *)dict{
   FIAddTextOption *opt = [FIAddTextOption new];
    
    NSArray *src = dict[@"texts"];
    NSMutableArray<FIAddText*> *arr = [NSMutableArray new];
    
    for (NSDictionary *dict in src) {
        FIAddText *addText = [FIAddText createFromDict:dict];
        [arr addObject:addText];
    }
    
    opt.texts =arr;
    
    return opt;
}

@end

@implementation FIEditorOptionGroup {
}

@end
