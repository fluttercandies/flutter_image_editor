//
//  FIUIImageHandler.m
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIUIImageHandler.h"
#import <GPUImage/GPUImage.h>
#import <CoreImage/CIFilterBuiltins.h>

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
      [self colorMatrix:(FIColorOption *)option];
    } else if ([option isKindOfClass:[FIScaleOption class]]) {
      [self scale:(FIScaleOption *)option];
    } else if ([option isKindOfClass:[FIAddTextOption class]]) {
      [self addText:(FIAddTextOption *)option];
    } else if ([option isKindOfClass:[FIMixImageOption class]]) {
      [self mixImage:(FIMixImageOption *)option];
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

+ (UIImage *)fixImageOrientation:(UIImage *)image {
  UIImageOrientation or = image.imageOrientation;
  if (or == UIImageOrientationUp) {
    return image;
  }

  UIGraphicsBeginImageContext(image.size);

  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];

  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  if (!result) {
    return image;
  } else {
    return result;
  }
}

- (void)fixOrientation {
  outImage = [FIUIImageHandler fixImageOrientation:outImage];
}

#pragma mark flip

- (void)flip:(FIFlipOption *)option {
  BOOL h = option.horizontal;
  BOOL v = option.vertical;
  if (!h && !v) {
    return;
  }

  CGSize size = outImage.size;

  //  UIGraphicsBeginImageContextWithOptions(size, YES, 1);
  UIGraphicsBeginImageContext(outImage.size);
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

  UIGraphicsBeginImageContext(outImage.size);

  //  UIGraphicsBeginImageContextWithOptions(newSize, YES, outImage.scale);

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  CGContextTranslateCTM(ctx, newSize.width / 2, newSize.height / 2);
  CGContextRotateCTM(ctx, redians);

  [outImage drawInRect:CGRectMake(-oldSize.width / 2, -oldSize.height / 2, oldSize.width,
                                  oldSize.height)];

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

#pragma mark color matrix


- (void)colorMatrix:(FIColorOption *)option {
  if (!outImage) {
    return;
  }
  
   CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
    NSObject<CIColorMatrix>* matrix = (NSObject<CIColorMatrix>*)filter;
    
    [filter setDefaults];
    
    CIImage *inputCIImage =  [[CIImage alloc]initWithImage:outImage options:nil];
    NSLog(@"input size = %@", NSStringFromCGRect([inputCIImage extent]));
    [matrix setValue:inputCIImage forKey:kCIInputImageKey];
//    [matrix setRVector:[self getCIVector:option start:0]];
    [matrix setValue:[self getCIVector:option start:0]  forKey:@"inputRVector"];
    [matrix setValue:[self getCIVector:option start:5]  forKey:@"inputGVector"];
    [matrix setValue:[self getCIVector:option start:10] forKey:@"inputBVector"];
    [matrix setValue:[self getCIVector:option start:15] forKey:@"inputAVector"];
    [matrix setValue:[self getOffsetCIVector:option] forKey:@"inputBiasVector"];
    
    CIImage *outputCIImage = [matrix outputImage];
    
    if(!outputCIImage){
        return;
    }
    
    CIContext *ctx = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ctx createCGImage:outputCIImage fromRect:[outputCIImage extent]];

    UIImage *newImage = [UIImage imageWithCGImage:cgImage];

    if(!newImage){
        return;
    }
    
    outImage = newImage;
}

-(CIVector*) getCIVector:(FIColorOption*)option start:(int)start{
    CGFloat v1 = [option getValue:start];
    CGFloat v2 = [option getValue:start+1];
    CGFloat v3 = [option getValue:start+2];
    CGFloat v4 = [option getValue:start+3];
    return [CIVector vectorWithX:v1 Y:v2 Z:v3 W:v4];
}

-(CIVector*) getOffsetCIVector:(FIColorOption*)option{
    CGFloat v1 = [option getValue:4];
    CGFloat v2 = [option getValue:9];
    CGFloat v3 = [option getValue:14];
    CGFloat v4 = [option getValue:19];
     return [CIVector vectorWithX:v1 Y:v2 Z:v3 W:v4];
}

#pragma mark scale

- (void)scale:(FIScaleOption *)option {
  if (!outImage) {
    return;
  }

  GPUImageFilter *filter = [GPUImageFilter new];
  CGSize size;

  if (outImage.imageOrientation == UIImageOrientationLeft ||
      outImage.imageOrientation == UIImageOrientationRight ||
      outImage.imageOrientation == UIImageOrientationLeftMirrored ||
      outImage.imageOrientation == UIImageOrientationRightMirrored) {
    size = CGSizeMake(option.height, option.width);
  } else {
    size = CGSizeMake(option.width, option.height);
  }

  [filter forceProcessingAtSize:size];
  [filter useNextFrameForImageCapture];

  GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:outImage];
  if (!pic) {
    return;
  }
  [pic addTarget:filter];
  [pic processImage];

  UIImage *image = [filter imageFromCurrentFramebufferWithOrientation:outImage.imageOrientation];
  if (image) {
    outImage = image;
  }
}

#pragma mark add text

- (void)addText:(FIAddTextOption *)option {
  if (!outImage) {
    return;
  }

  if (option.texts.count == 0) {
    return;
  }

  //  UIGraphicsBeginImageContextWithOptions(outImage.size, YES, outImage.scale);
  UIGraphicsBeginImageContext(outImage.size);

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  [outImage drawInRect:CGRectMake(0, 0, outImage.size.width, outImage.size.height)];

  for (FIAddText *text in option.texts) {
    UIColor *color = [UIColor colorWithRed:text.r green:text.g blue:text.b alpha:text.a];

    NSDictionary *attr = @{
      NSFontAttributeName : [UIFont boldSystemFontOfSize:text.fontSizePx],
      NSForegroundColorAttributeName : color,
      NSBackgroundColorAttributeName : UIColor.clearColor,
    };

    CGFloat w = outImage.size.width - text.x;
    CGFloat h = outImage.size.height - text.y;

    CGRect rect = CGRectMake(text.x, text.y, w, h);

    [text.text drawInRect:rect withAttributes:attr];
  }

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  if (!newImage) {
    return;
  }

  outImage = newImage;
}

#pragma mark mix image

- (void)mixImage:(FIMixImageOption *)option {
  if (!outImage) {
    return;
  }

  //  UIGraphicsBeginImageContextWithOptions(outImage.size, YES, outImage.scale);
  UIGraphicsBeginImageContext(outImage.size);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  CGRect srcRect = CGRectMake(option.x, option.y, option.width, option.height);
  CGRect dstRect = CGRectMake(0, 0, outImage.size.width, outImage.size.height);
  if ([option.blendMode isEqualToNumber:@(kCGBlendModeDst)]) {
    [outImage drawInRect:dstRect blendMode:[option.blendMode intValue] alpha:YES];
  } else if ([option.blendMode isEqualToNumber:@(kCGBlendModeSrc)]) {
    UIImage *src = [UIImage imageWithData:option.src];
    [src drawInRect:srcRect blendMode:[option.blendMode intValue] alpha:YES];
  } else {
    [outImage drawInRect:dstRect];
    UIImage *src = [UIImage imageWithData:option.src];
    [src drawInRect:srcRect blendMode:[option.blendMode intValue] alpha:YES];
  }

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  if (!newImage) {
    return;
  }

  outImage = newImage;
}

@end
