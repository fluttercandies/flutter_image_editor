//
// Created by cjl on 2020/5/21.
//

#import <Foundation/Foundation.h>
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

-(CGFloat)getValue:(int)index;
@end

@interface FIScaleOption : NSObject <FIOption>
@property(assign, nonatomic) int width;
@property(assign, nonatomic) int height;
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

@protocol FIValues <NSObject>
@property(nonatomic, strong)NSDictionary *values;
@end

@interface FIDrawOption : NSObject <FIOption,FIValues>

@property(nonatomic,strong) NSArray *parts;

@end

@protocol FIHavePaint <NSObject,FIValues>

@end

NS_ASSUME_NONNULL_END
