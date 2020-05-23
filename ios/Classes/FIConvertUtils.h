//
// Created by cjl on 2020/5/21.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

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
@end

@interface FIScaleOption : NSObject <FIOption>
@property(assign, nonatomic) int width;
@property(assign, nonatomic) int height;
@end

@interface FIEditorOptionGroup : NSObject
@property(nonatomic, strong) FIFormatOption *fmt;
@property(nonatomic, strong) NSArray *options;
@end

NS_ASSUME_NONNULL_END
