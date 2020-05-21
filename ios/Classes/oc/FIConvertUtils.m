//
// Created by cjl on 2020/5/21.
//

#import "FIConvertUtils.h"


@implementation FIConvertUtils {

}
+ (FIEditorOptionGroup *)getOptions:(NSArray<NSDictionary *> *)dict {
  FIEditorOptionGroup *group = [FIEditorOptionGroup new];
  for (NSDictionary *map in dict) {
    NSString *type = (NSString *) map[@"type"];
    NSDictionary *value = map[@"value"];
    if ([@"flip" isEqualToString:type]) {
      group.flip = [FIFlipOption createFromDict:value];
    } else if ([@"clip" isEqualToString:type]) {
      group.clip = [FIClipOption createFromDict:value];
    } else if ([@"rotate" isEqualToString:type]) {
      group.rotate = [FIRotateOption createFromDict:value];
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

@implementation FIEditorOptionGroup {

}

@end