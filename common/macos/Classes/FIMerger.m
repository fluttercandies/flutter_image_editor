//
//  FIMerger.m
//  GPUImage
//
//  Created by Caijinglong on 2020/5/27.
//

#import "FIMerger.h"
#import "FIUIImageHandler.h"

@implementation FIMerger {
}

- (NSData *)process {
  FIMergeOption *opt = self.option;

  CGContextRef ctx = createCGContext(opt.size.width, opt.size.height);
  if (!ctx) {
    return nil;
  }

  for (FIMergeImage *mergeImage in opt.images) {
    CGRect rect = CGRectMake(mergeImage.x, mergeImage.y, mergeImage.width, mergeImage.height);
    CGImageRef ref = [[[NSImage alloc] initWithData:mergeImage.data] CGImage];
    CGContextDrawImage(ctx, rect, ref);
  }

  FIImage *newImage = getImageFromCGContext(ctx);

  releaseCGContext(ctx);
  if (!newImage) {
    return nil;
  }

  return [self outputMemory:newImage];
}

- (NSData *)outputMemory:(FIImage *)image {
  FIFormatOption *fmt = self.option.format;

  CGImageRef ref = [image CGImage];

  NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:ref];

  if (fmt.format == 0) {
    return [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
  } else {
    NSDictionary *props = @{NSImageCompressionFactor: @((fmt.quality / 100))};
    return [bitmap representationUsingType:NSBitmapImageFileTypeJPEG properties:props];
  }
}

- (NSString *)makeOutputPath {
  NSString *extName = self.option.format.format == 1 ? @"jpg" : @"png";
  NSString *cachePath =
      NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
  long time = (long)[NSDate date].timeIntervalSince1970;
  return [NSString stringWithFormat:@"%@/%ld.%@", cachePath, time, extName];
}

@end
