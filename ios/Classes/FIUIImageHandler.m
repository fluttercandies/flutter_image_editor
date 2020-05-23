//
//  FIUIImageHandler.m
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIUIImageHandler.h"

@implementation FIUIImageHandler {
  UIImage *outImage;
}

- (void)handleImage {
  outImage = self.image;
  [self fixOrientation];
  for (NSObject<FIOption> *option in self.optionGroup.options) {
    if ([option isKindOfClass:[FIFlipOption class]]) {
      [self flip:(FIFlipOption *)option];
    } else if ([option isKindOfClass:[FIClipOption class]]) {
      [self clip:(FIClipOption *)option];
    } else if ([option isKindOfClass:[FIRotateOption class]]) {
      [self rotate:(FIRotateOption *)option];
    } else if ([option isKindOfClass:[FIColorOption class]]) {
      [self color:(FIColorOption *)option];
    }
  }
}

#pragma mark output

- (BOOL)outputFile:(NSString *)targetPath {
  NSData *data = [self outputMemory];
  if (!data) {
    return NO;
  }
  NSURL *url = [NSURL URLWithString:targetPath];
  [data writeToURL:url atomically:YES];
  return YES;
}

- (NSData *)outputMemory {
  FIFormatOption *fmt = self.optionGroup.fmt;
  if (fmt.format == 0) {
    return UIImagePNGRepresentation(outImage);
  } else {
    return UIImageJPEGRepresentation(outImage, ((CGFloat)fmt.quality) / 100);
  }
}

- (void)fixOrientation {
  UIImageOrientation or = outImage.imageOrientation;
  if (or == UIImageOrientationUp) {
    return;
  }

  UIGraphicsBeginImageContextWithOptions(outImage.size, NO, outImage.scale);

  [outImage
      drawInRect:CGRectMake(0, 0, outImage.size.width, outImage.size.height)];

  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  if (result) {
    outImage = result;
  }
}

#pragma mark flip

- (void)flip:(FIFlipOption *)option {
  BOOL h = option.horizontal;
  BOOL v = option.vertical;
  if (!h && !v) {
    return;
  }

  CGSize size = outImage.size;

  UIGraphicsBeginImageContextWithOptions(size, NO, 1);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  CGImageRef cg = outImage.CGImage;

  if (cg == nil) {
    return;
  }

  CGRect rect = CGRectMake(0, 0, size.width, size.height);

  CGContextClipToRect(ctx, rect);

  if (!v && h) {
    CGContextRotateCTM(ctx, M_PI);
    CGContextTranslateCTM(ctx, -size.width, -size.height);
  } else if (v && !h) {
  } else if (v && h) {
    CGContextTranslateCTM(ctx, size.width, 0);
    CGContextScaleCTM(ctx, -1, 1);
  } else {
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
  }

  CGContextDrawImage(ctx, rect, cg);

  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  if (!result.CGImage) {
    return;
  }

  outImage = [UIImage imageWithCGImage:result.CGImage
                                 scale:1
                           orientation:[outImage imageOrientation]];
}

#pragma mark clip

- (void)clip:(FIClipOption *)option {
  CGImageRef cg = outImage.CGImage;
  CGRect rect = CGRectMake(option.x, option.y, option.width, option.height);
  CGImageRef resultCg = CGImageCreateWithImageInRect(cg, rect);
  outImage = [UIImage imageWithCGImage:resultCg];
}

#pragma mark rotate

- (void)rotate:(FIRotateOption *)option {
  CGFloat redians = [self convertDegreeToRadians:option.degree];
  CGSize oldSize = outImage.size;
  CGRect oldRect = CGRectMake(0, 0, oldSize.width, oldSize.height);
  CGAffineTransform aff = CGAffineTransformMakeRotation(redians);
  CGRect newRect = CGRectApplyAffineTransform(oldRect, aff);
  CGSize newSize = newRect.size;

  UIGraphicsBeginImageContextWithOptions(newSize, NO, outImage.scale);

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  CGContextTranslateCTM(ctx, newSize.width / 2, newSize.height / 2);
  CGContextRotateCTM(ctx, redians);

  [outImage drawInRect:CGRectMake(-oldSize.width / 2, -oldSize.height / 2,
                                  oldSize.width, oldSize.height)];

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  if (!newImage) {
    return;
  }

  outImage = newImage;
}

- (CGFloat)convertDegreeToRadians:(CGFloat)degree {
  return degree * M_PI / 180;
}

#pragma mark color(hsb)

- (void)color:(FIColorOption *)option {
  if (!outImage) {
    return;
  }
  CIContext *context = [CIContext contextWithOptions:nil];
  CIImage *ciImage = [CIImage imageWithCGImage:outImage.CGImage];
  if (!ciImage) {
    return;
  }
  CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];

  [filter setValue:ciImage forKey:kCIInputImageKey];
  [filter setValue:@(option.bright) forKey:kCIInputBrightnessKey];
  [filter setValue:@(option.sat) forKey:kCIInputSaturationKey];
  [filter setValue:@(option.contrast) forKey:kCIInputContrastKey];

  CIImage *result = [filter valueForKey:kCIOutputImageKey];
  CGImageRef cgImage = [context createCGImage:result fromRect:ciImage.extent];

  UIImage *target = [UIImage imageWithCGImage:cgImage];

  CGImageRelease(cgImage);

  if (!target) {
    return;
  }
  outImage = target;
}

@end
