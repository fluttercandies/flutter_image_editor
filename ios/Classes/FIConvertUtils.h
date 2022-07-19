//
// Created by cjl on 2020/5/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kCGBlendModeSrc 12345
#define kCGBlendModeDst 12346

@class FIEditorOptionGroup;

@interface FIConvertUtils : NSObject

+ (FIEditorOptionGroup *)getOptions:(NSArray<NSDictionary *> *)dict;

@end

@protocol FIOption

+ (id)createFromDict:(NSDictionary *)dict;

@end

@interface FIFlipOption : NSObject <FIOption>

@property(assign, nonatomic) BOOL horizontal;
@property(assign, nonatomic) BOOL vertical;

@end

@interface FIClipOption : NSObject <FIOption>

@property(assign, nonatomic) int x;
@property(assign, nonatomic) int y;
@property(assign, nonatomic) int width;
@property(assign, nonatomic) int height;

@end

@interface FIRotateOption : NSObject <FIOption>

@property(assign, nonatomic) int degree;

@end

@interface FIFormatOption : NSObject <FIOption>

@property(assign, nonatomic) int format;
@property(assign, nonatomic) int quality;

@end

@interface FIColorOption : NSObject <FIOption>

@property(strong, nonatomic) NSArray *matrix;

- (CGFloat)getValue:(int)index;

@end

@interface FIScaleOption : NSObject <FIOption>

@property(assign, nonatomic) int width;
@property(assign, nonatomic) int height;
@property(assign, nonatomic) BOOL keepRatio;
@property(assign, nonatomic) BOOL keepWidthFirst;

@end

@interface FIAddText : NSObject <FIOption>

@property(nonatomic, copy) NSString *text;
@property(nonatomic, assign) int x;
@property(nonatomic, assign) int y;
@property(nonatomic, assign) int fontSizePx;
@property(nonatomic, assign) int r;
@property(nonatomic, assign) int g;
@property(nonatomic, assign) int b;
@property(nonatomic, assign) int a;
@property(nonatomic, assign) NSString *fontName;

@end

@interface FIAddTextOption : NSObject <FIOption>

@property(nonatomic, strong) NSArray<FIAddText *> *texts;

@end

@interface FIMixImageOption : NSObject <FIOption>

@property(nonatomic, assign) int x;
@property(nonatomic, assign) int y;
@property(nonatomic, assign) int width;
@property(nonatomic, assign) int height;
@property(nonatomic, strong) NSData *src;
@property(nonatomic, strong) NSNumber *blendMode;

@end

@interface FIEditorOptionGroup : NSObject

@property(nonatomic, strong) FIFormatOption *fmt;
@property(nonatomic, strong) NSArray *options;

@end

@interface FIMergeImage : NSObject <FIOption>

@property(nonatomic, strong) NSData *data;
@property(nonatomic, assign) int x;
@property(nonatomic, assign) int y;
@property(nonatomic, assign) int width;
@property(nonatomic, assign) int height;

@end

@interface FIMergeOption : NSObject <FIOption>

@property(nonatomic, strong) NSArray<FIMergeImage *> *images;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, strong) FIFormatOption *format;

@end

@interface FIValueOption : NSObject

@property(nonatomic, strong) NSDictionary *map;

@end

@interface FIPaint : FIValueOption <FIOption>

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, assign) int paintWeight;
@property(nonatomic, assign) bool fill;

- (float)r;

- (float)g;

- (float)b;

- (float)a;

@end

@interface FIDrawPart : FIValueOption <FIOption>

- (FIPaint *)paint;

- (CGRect)rect:(NSString *)key;

- (CGPoint)point:(NSString *)key;

@end

@interface FIDrawOption : FIValueOption <FIOption>

- (NSArray<FIDrawPart *> *)parts;

@end

@interface FILineDrawPart : FIDrawPart

- (CGPoint)start;

- (CGPoint)end;

@end

@interface FIPointsDrawPart : FIDrawPart

- (NSArray *)points;

@end

@interface FIRectDrawPart : FIDrawPart

- (CGRect)rect;

@end

@interface FIOvalDrawPart : FIDrawPart

- (CGRect)rect;

@end

@interface FIPathDrawPart : FIDrawPart

- (NSArray<FIDrawPart *> *)parts;

- (BOOL) autoClose;

@end

@interface FIPathMove : FIDrawPart

- (CGPoint)offset;
@end


@interface FIPathLine : FIDrawPart

- (CGPoint)offset;

@end

@interface FIPathArc : FIDrawPart

- (CGFloat)start;

- (CGFloat)sweep;

- (BOOL)useCenter;

- (CGRect)rect;

@end

@interface FIPathBezier : FIDrawPart

- (int)kind;

- (CGPoint)target;

- (CGPoint)control1;

- (CGPoint)control2;

@end

NS_ASSUME_NONNULL_END
