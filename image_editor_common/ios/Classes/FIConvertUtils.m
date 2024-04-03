//
// Created by cjl on 2020/5/21.
//

#import "FIConvertUtils.h"
#import <Flutter/Flutter.h>

@implementation FIConvertUtils

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
        } else if ([@"draw" isEqualToString:type]) {
            option = [FIDrawOption createFromDict:value];
        }
        if (option) {
            [optionArray addObject:option];
        }
    }
    return group;
}

@end

@implementation FIFlipOption

+ (id)createFromDict:(NSDictionary *)dict {
    FIFlipOption *option = [FIFlipOption new];
    option.horizontal = [dict[@"h"] boolValue];
    option.vertical = [dict[@"v"] boolValue];
    return option;
}

@end

@implementation FIClipOption

+ (id)createFromDict:(NSDictionary *)dict {
    FIClipOption *option = [FIClipOption new];
    option.x = [dict[@"x"] intValue];
    option.y = [dict[@"y"] intValue];
    option.width = [dict[@"width"] intValue];
    option.height = [dict[@"height"] intValue];
    return option;
}

@end

@implementation FIRotateOption

+ (id)createFromDict:(NSDictionary *)dict {
    FIRotateOption *option = [FIRotateOption new];
    option.degree = [dict[@"degree"] intValue];
    return option;
}

@end

@implementation FIFormatOption

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
    option.keepRatio = [dict[@"keepRatio"] boolValue];
    option.keepWidthFirst = [dict[@"keepWidthFirst"] boolValue];
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
    text.fontName = dict[@"fontName"];
    text.textAlign = dict[@"textAlign"];
    return text;
}

-(NSMutableParagraphStyle*) getParagraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    if ([self.textAlign isEqualToString:@"left"]) {
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
    } else if ([self.textAlign isEqualToString:@"center"]) {
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
    } else if ([self.textAlign isEqualToString:@"right"]) {
        [paragraphStyle setAlignment:NSTextAlignmentRight];
    } else {
        // 如果textAlign不是预期的任何一个值，可以默认设置为左对齐或其他适当的对齐方式
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
    }
    
    return paragraphStyle;
}

@end

@implementation FIAddTextOption

+ (id)createFromDict:(NSDictionary *)dict {
    FIAddTextOption *opt = [FIAddTextOption new];
    NSArray *src = dict[@"texts"];
    NSMutableArray<FIAddText *> *arr = [NSMutableArray new];
    for (NSDictionary *value in src) {
        FIAddText *addText = [FIAddText createFromDict:value];
        [arr addObject:addText];
    }
    opt.texts = arr;
    return opt;
}

@end

static NSDictionary *mixBlendModeDict;

@implementation FIMixImageOption

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

@implementation FIEditorOptionGroup
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
    for (NSDictionary *value in imageOpt) {
        [optionArray addObject:[FIMergeImage createFromDict:value]];
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
                part = [FIOvalDrawPart createFromDict:value];
            } else if ([key isEqualToString:@"line"]) {
                part = [FILineDrawPart createFromDict:value];
            } else if ([key isEqualToString:@"point"]) {
                part = [FIPointsDrawPart createFromDict:value];
            } else if ([key isEqualToString:@"path"]) {
                part = [FIPathDrawPart createFromDict:value];
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
    CGFloat r = [ins r];
    CGFloat g = [ins g];
    CGFloat b = [ins b];
    CGFloat a = [ins a];
    ins.color = [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a / 255.0];
    return ins;
}

- (float)r {
    return [self.map[@"color"][@"r"] floatValue] / 255;
}

- (float)g {
    return [self.map[@"color"][@"g"] floatValue] / 255;
}

- (float)b {
    return [self.map[@"color"][@"b"] floatValue] / 255 ;
}

- (float)a {
    return [self.map[@"color"][@"a"] floatValue] / 255;
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

@implementation FILineDrawPart

+ (id)createFromDict:(NSDictionary *)dict {
    FILineDrawPart *part = [FILineDrawPart new];
    part.map = dict;
    return part;
}

- (CGPoint)start {
    return [self point:@"start"];
}


- (CGPoint)end {
    return [self point:@"end"];
}

@end

@implementation FIPointsDrawPart

+ (id)createFromDict:(NSDictionary *)dict {
    FIPointsDrawPart *part = [FIPointsDrawPart new];
    part.map = dict;
    return part;
}

- (NSArray *)points {
    NSMutableArray *result = [NSMutableArray new];
    NSArray *offsets = self.map[@"offset"];
    for (NSDictionary *map in offsets) {
        int x = [map[@"x"] intValue];
        int y = [map[@"y"] intValue];
        CGPoint point = CGPointMake(x, y);
        [result addObject:[NSValue valueWithCGPoint:point]];
    }
    return result;
}

@end

@implementation FIRectDrawPart

+ (id)createFromDict:(NSDictionary *)dict {
    FIRectDrawPart *part = [FIRectDrawPart new];
    part.map = dict;
    return part;
}

- (CGRect)rect {
    return [self rect:@"rect"];
}

@end

@implementation FIOvalDrawPart

+ (id)createFromDict:(NSDictionary *)dict {
    FIOvalDrawPart *part = [FIOvalDrawPart new];
    part.map = dict;
    return part;
}

- (CGRect)rect {
    return [self rect:@"rect"];
}

@end

@implementation FIPathDrawPart

+ (id)createFromDict:(NSDictionary *)dict {
    FIPathDrawPart *part = [FIPathDrawPart new];
    part.map = dict;
    return part;
}

- (BOOL)autoClose {
    return [self.map[@"autoClose"] boolValue];
}

- (NSArray<FIDrawPart *> *)parts {
    NSMutableArray *result = [NSMutableArray new];
    NSArray *arr = self.map[@"parts"];
    for (int i = 0; i < arr.count; ++i) {
        NSDictionary *kv = arr[(NSUInteger) i];
        NSString *key = kv[@"key"];
        NSDictionary *value = kv[@"value"];
        if (key && value) {
            FIDrawPart *part;
            if ([key isEqualToString:@"move"]) {
                part = [FIPathMove createFromDict:value];
            } else if ([key isEqualToString:@"lineTo"]) {
                part = [FIPathLine createFromDict:value];
            } else if ([key isEqualToString:@"bezier"]) {
                part = [FIPathBezier createFromDict:value];
            } else if ([key isEqualToString:@"arcTo"]) {
                part = [FIPathArc createFromDict:value];
            }
            if (part) {
                [result addObject:part];
            }
        }
    }
    return result;
}

@end

@implementation FIPathMove

+ (id)createFromDict:(NSDictionary *)dict {
    FIPathMove *ins = [FIPathMove new];
    ins.map = dict;
    return ins;
}

- (CGPoint)offset {
    return [self point:@"offset"];
}

@end

@implementation FIPathLine

+ (id)createFromDict:(NSDictionary *)dict {
    FIPathLine *ins = [FIPathLine new];
    ins.map = dict;
    return ins;
}

- (CGPoint)offset {
    return [self point:@"offset"];
}

@end

@implementation FIPathArc

+ (id)createFromDict:(NSDictionary *)dict {
    FIPathArc *ins = [FIPathArc new];
    ins.map = dict;
    return ins;
}

- (CGFloat)start {
    return [self.map[@"start"] floatValue];
}

- (CGFloat)sweep {
    return [self.map[@"sweep"] floatValue];
}

- (BOOL)useCenter {
    return [self.map[@"sweep"] boolValue];
}

- (CGRect)rect {
    return [self rect:@"rect"];
}

@end

@implementation FIPathBezier

+ (id)createFromDict:(NSDictionary *)dict {
    FIPathBezier *ins = [FIPathBezier new];
    ins.map = dict;
    return ins;
}

- (int)kind {
    return [self.map[@"kind"] intValue];
}

- (CGPoint)target {
    return [self point:@"target"];
}


- (CGPoint)control1 {
    return [self point:@"c1"];
}


- (CGPoint)control2 {
    return [self point:@"c2"];
}

@end
