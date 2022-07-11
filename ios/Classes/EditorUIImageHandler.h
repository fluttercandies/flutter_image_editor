//
//  FIUIImageHandler.h
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "FIConvertUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditorUIImageHandler : NSObject

@property(strong, nonatomic) UIImage *image;
@property(strong, nonatomic) FIEditorOptionGroup *optionGroup;

- (void)handleImage;

- (BOOL)outputFile:(NSString *)targetPath;

- (NSData *)outputMemory;

+ (UIImage *)fixImageOrientation:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
