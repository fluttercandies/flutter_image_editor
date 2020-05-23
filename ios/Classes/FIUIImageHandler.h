//
//  FIUIImageHandler.h
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIConvertUtils.h"
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FIUIImageHandler : NSObject

@property(strong, nonatomic) UIImage *image;
@property(strong, nonatomic) FIEditorOptionGroup *optionGroup;

- (void)handleImage;

- (BOOL)outputFile:(NSString *)targetPath;

- (NSData *)outputMemory;

@end

NS_ASSUME_NONNULL_END
