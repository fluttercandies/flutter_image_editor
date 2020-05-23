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
      group.flip = [FIFlipOption createFromDict:value];
      option = group.flip;
    } else if ([@"clip" isEqualToString:type]) {
      group.clip = [FIClipOption createFromDict:value];
      option = group.clip;
    } else if ([@"rotate" isEqualToString:type]) {
      group.rotate = [FIRotateOption createFromDict:value];
      option = group.rotate;
    } else if ([@"rotate" isEqualToString:type]) {
      group.rotate = [FIRotateOption createFromDict:value];
      option = group.rotate;
    } else if ([@"color" isEqualToString:type]){
        group.color = [FIColorOption createFromDict:value];
        option = group.color;
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
  FIColorOption *option = [FIColorOption new];
  option.bright = [dict[@"b"] doubleValue];
  option.sat = [dict[@"s"] doubleValue];
  option.contrast = [dict[@"c"] doubleValue];

  return option;
}

@end

@implementation FIEditorOptionGroup {
}

@end
