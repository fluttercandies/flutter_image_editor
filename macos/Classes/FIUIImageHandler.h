//
//  FIUIImageHandler.h
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIImport.h"
#import <Foundation/Foundation.h>
#import "FIConvertUtils.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef TARGET_OS_OSX

@interface NSImage (ext)
- (CGSize)pixelSize;

- (CGFloat)retinaScale;

- (CGImageRef)CGImage;

- (CIImage *)CIImage;

@end

#endif

void releaseCGContext(CGContextRef ref);

CGContextRef createCGContext(size_t pixelsWide, size_t pixelsHigh);

FIImage *getImageFromCGContext(CGContextRef context);

@interface FIUIImageHandler : NSObject

@property(strong, nonatomic) FIImage *image;
@property(strong, nonatomic) FIEditorOptionGroup *optionGroup;

- (void)handleImage;

- (BOOL)outputFile:(NSString *)targetPath;

- (NSData *)outputMemory;

+ (FIImage *)fixImageOrientation:(FIImage *)image;


@end

NS_ASSUME_NONNULL_END
