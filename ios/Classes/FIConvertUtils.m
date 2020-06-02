//
// Created by cjl on 2020/5/21.
//

#import "FIConvertUtils.h"
#import <Flutter/Flutter.h>

@implementation FIConvertUtils {
}
+ (FIEditorOptionGroup *)getOptions:(NSArray<NSDictionary *> *)dict {
  FIEditorOptionGroup *group = [FIEditorOptionGroup new];
  NSMutableArray *optionArray = [NSMutableArray new];
  group.options = optionArray;
  for (NSDictionary *map in dict) {
    NSString *type = (NSString *) map[@"type"];
    NSDictionary *value = map[@"value"];
    NSObject <FIOption> *option;
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
    } else if ([@"mix_image" isEqualToString:type]) {
      option = [FIMixImageOption createFromDict:value];
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

- (CGFloat)getValue:(int)index {
  return [self.matrix[index] floatValue];
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
+ (id)createFromDict:(NSDictionary *)dict {
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

+ (id)createFromDict:(NSDictionary *)dict {
  FIAddTextOption *opt = [FIAddTextOption new];

  NSArray *src = dict[@"texts"];
  NSMutableArray<FIAddText *> *arr = [NSMutableArray new];

  for (NSDictionary *dict in src) {
    FIAddText *addText = [FIAddText createFromDict:dict];
    [arr addObject:addText];
  }

  opt.texts = arr;

  return opt;
}

@end

static NSDictionary *mixBlendModeDict;

@implementation FIMixImageOption {
}

+ (id)createFromDict:(NSDictionary *)dict {
  if (!mixBlendModeDict) {
    mixBlendModeDict = @{
            @"clear": @(kCGBlendModeClear),
            @"src": @(kCGBlendModeSrc),
            @"dst": @(kCGBlendModeDst),
            @"srcOver": @(kCGBlendModeNormal),
            @"dstOver": @(kCGBlendModeDestinationOver),
            @"srcIn": @(kCGBlendModeSourceIn),
            @"dstIn": @(kCGBlendModeDestinationIn),
            @"srcOut": @(kCGBlendModeSourceOut),
            @"dstOut": @(kCGBlendModeDestinationOver),
            @"srcATop": @(kCGBlendModeSourceAtop),
            @"dstATop": @(kCGBlendModeDestinationAtop),
            @"xor": @(kCGBlendModeXOR),
            @"darken": @(kCGBlendModeDarken),
            @"lighten": @(kCGBlendModeLighten),
            @"multiply": @(kCGBlendModeMultiply),
            @"screen": @(kCGBlendModeScreen),
            @"overlay": @(kCGBlendModeOverlay),

    };
  }

  FIMixImageOption *option = [FIMixImageOption new];

  option.x = [dict[@"x"] intValue];
  option.y = [dict[@"y"] intValue];
  option.width = [dict[@"w"] intValue];
  option.height = [dict[@"h"] intValue];

  option.src = ((FlutterStandardTypedData *) dict[@"target"][@"memory"]).data;
  NSString *modeString = dict[@"mixMode"];
  option.blendMode = mixBlendModeDict[modeString];

  return option;
}
@end

@implementation FIEditorOptionGroup {
}

@end

@implementation FIMergeImage

+ (nonnull id)createFromDict:(nonnull NSDictionary *)dict {
  FIMergeImage *image = [FIMergeImage new];

  image.data = ((FlutterStandardTypedData *) dict[@"src"][@"memory"]).data;
  NSDictionary *position = dict[@"position"];
  image.x = [position[@"x"] intValue];
  image.y = [position[@"y"] intValue];
  image.width = [position[@"w"] intValue];
  image.height = [position[@"h"] intValue];

  return image;
}

@end

@implementation FIMergeOption

+ (nonnull id)createFromDict:(nonnull NSDictionary *)dict {
  FIMergeOption *opt = [FIMergeOption new];

  NSArray *imageOpt = dict[@"images"];

  NSMutableArray *optionArray = [NSMutableArray new];
  opt.images = optionArray;
  for (NSDictionary *dict in imageOpt) {
    [optionArray addObject:[FIMergeImage createFromDict:dict]];
  }

  int w = [dict[@"w"] intValue];
  int h = [dict[@"h"] intValue];

  opt.size = CGSizeMake(w, h);

  opt.format = [FIFormatOption createFromDict:dict[@"fmt"]];

  return opt;
}

@end

@implementation FIDrawOption

+ (nonnull id)createFromDict:(nonnull NSDictionary *)dict {
  FIDrawOption *option = [FIDrawOption new];
  option.map = dict;
  return option;
}

- (NSArray<FIDrawPart *> *)parts {
  NSMutableArray *array = [NSMutableArray new];
  for (NSDictionary *dict in self.map[@"parts"]) {
    NSString *key = dict[@"key"];
    NSDictionary *value = dict[@"value"];
    if (key) {
      FIDrawPart *part;
      if ([key isEqualToString:@"rect"]) {
        part = [FIRectDrawPart createFromDict:value];
      } else if ([key isEqualToString:@"oval"]) {

      } else if ([key isEqualToString:@"line"]) {

      } else if ([key isEqualToString:@"point"]) {

      } else if ([key isEqualToString:@"path"]) {

      }

      if (part) {
        [array addObject:part];
      }
    }
  }

  return array;
}

@end

@implementation FIPaint

+ (id)createFromDict:(NSDictionary *)dict {
  FIPaint *ins = [FIPaint new];
  ins.map = dict;

  ins.fill = [dict[@"paintStyleFill"] boolValue];
  ins.paintWeight = [dict[@"lineWeight"] intValue];
  NSDictionary *colorMap = dict[@"color"];
  int r = [colorMap[@"r"] intValue];
  int g = [colorMap[@"g"] intValue];
  int b = [colorMap[@"b"] intValue];
  int a = [colorMap[@"a"] intValue];
  ins.color = [UIColor colorWithRed:r green:g blue:b alpha:a];

  return ins;
}


@end

@implementation FIDrawPart
+ (id)createFromDict:(NSDictionary *)dict {
  FIDrawPart *ins = [FIDrawPart new];
  ins.map = dict;
  return ins;
}

- (FIPaint *)paint {
  return [FIPaint createFromDict:self.map[@"paint"]];
}

- (CGRect)rect:(NSString *)key {
  NSDictionary *m = self.map[key];
  float left = [m[@"left"] floatValue];
  float top = [m[@"top"] floatValue];
  float w = [m[@"width"] floatValue];
  float h = [m[@"height"] floatValue];
  CGRect result = CGRectMake(left, top, w, h);
  return result;
}

- (CGPoint)point:(NSString *)key {
  NSDictionary *m = self.map[key];
  float x = [m[@"x"] floatValue];
  float y = [m[@"y"] floatValue];
  return CGPointMake(x, y);
}


@end

@implementation FIValueOption
@end

@implementation FIRectDrawPart

+ (id)createFromDict:(NSDictionary *)dict {
  FIRectDrawPart *part = [FIRectDrawPart new];
  part.map = dict;
  return part;
}

@end