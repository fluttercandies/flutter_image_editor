//
//  FIUIImageHandler.m
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIUIImageHandler.h"
#import "FICommonUtils.h"
#import <CoreImage/CIFilterBuiltins.h>
#import <CoreImage/CoreImage.h>

#if TARGET_OS_OSX

void releaseCGContext(CGContextRef ref) {
    char *bitmapData = CGBitmapContextGetData(ref);
    if (bitmapData) free(bitmapData);
    CGContextRelease(ref);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
CGContextRef createCGContext(size_t pixelsWide, size_t pixelsHigh) {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    size_t bitmapByteCount;
    size_t bitmapBytesPerRow;

    bitmapBytesPerRow = (pixelsWide * 4);// 1
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);

    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);// 2
    bitmapData = calloc(bitmapByteCount, sizeof(uint8_t));// 3
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate(bitmapData,// 4
        pixelsWide,
        pixelsHigh,
        8,      // bits per component
        bitmapBytesPerRow,
        colorSpace,
        kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        free(bitmapData);// 5
        fprintf(stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease(colorSpace);// 6

    return context;// 7
}

#pragma clang diagnostic pop

CGSize CGImageGetSize(CGImageRef ref) {
    size_t w = CGImageGetWidth(ref);
    size_t h = CGImageGetHeight(ref);
    return CGSizeMake(w, h);
}

FIImage *getImageFromCGContext(CGContextRef context) {
    size_t h = CGBitmapContextGetHeight(context);
    size_t w = CGBitmapContextGetWidth(context);

    CGImageRef pImage = CGBitmapContextCreateImage(context);

    NSImage *image = [[FIImage alloc] initWithCGImage:pImage size:CGSizeMake(w, h)];
    CGImageRelease(pImage);
    return image;
}


@implementation NSImage (ext)
- (CGSize)pixelSize {
    if (self.representations.count == 0) {
        return self.size;
    }
    NSInteger width = self.representations[0].pixelsWide;
    NSInteger height = self.representations[0].pixelsHigh;
    return CGSizeMake(width, height);
}

- (CGFloat)retinaScale {
    if (self.pixelSize.width == 0) {
        return 1;
    }
    return self.pixelSize.width / self.size.width;
}

- (CGImageRef)CGImage {
    CGRect rect = CGRectMake(0, 0, self.pixelSize.width, self.pixelSize.height);
    return [self CGImageForProposedRect:&rect context:nil hints:nil];
}


- (CIImage *)CIImage {
    CGImageRef srcImage = [self CGImage];
    return [[CIImage alloc] initWithCGImage:srcImage];
}

@end

#endif

@implementation FIUIImageHandler {
    FIImage *outImage;
}

- (void)handleImage {
    outImage = self.image;
    [self fixOrientation];
    for (NSObject <FIOption> *option in self.optionGroup.options) {
        if ([option isKindOfClass:[FIFlipOption class]]) {
            [self flip:(FIFlipOption *) option];
        } else if ([option isKindOfClass:[FIClipOption class]]) {
            [self clip:(FIClipOption *) option];
        } else if ([option isKindOfClass:[FIRotateOption class]]) {
            [self rotate:(FIRotateOption *) option];
        } else if ([option isKindOfClass:[FIColorOption class]]) {
            [self colorMatrix:(FIColorOption *) option];
        } else if ([option isKindOfClass:[FIScaleOption class]]) {
            [self scale:(FIScaleOption *) option];
        } else if ([option isKindOfClass:[FIAddTextOption class]]) {
            [self addText:(FIAddTextOption *) option];
        } else if ([option isKindOfClass:[FIMixImageOption class]]) {
            [self mixImage:(FIMixImageOption *) option];
        } else if ([option isKindOfClass:[FIDrawOption class]]) {
            [self drawImage:(FIDrawOption *) option];
        }
    }
}

#pragma mark output

- (BOOL)outputFile:(NSString *)targetPath {
    NSData *data = [self outputMemory];
    if (!data) {
        return NO;
    }
    NSURL *url = [NSURL fileURLWithPath:targetPath];
    [data writeToURL:url atomically:YES];
    return YES;
}

- (void)fixOrientation {
    outImage = [FIUIImageHandler fixImageOrientation:outImage];
}

#if TARGET_OS_OSX

- (FIImage *)getImageWith:(CGContextRef)context {
    return getImageFromCGContext(context);
}

- (NSData *)outputMemory {
    FIFormatOption *fmt = self.optionGroup.fmt;

    CGImageRef ref = [outImage CGImage];

    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:ref];

    if (fmt.format == 0) {
        return [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    } else {
        NSDictionary *props = @{NSImageCompressionFactor: @((fmt.quality / 100))};
        return [bitmap representationUsingType:NSBitmapImageFileTypeJPEG properties:props];
    }
}

+ (FIImage *)fixImageOrientation:(FIImage *)image {
    CGSize size = image.pixelSize;
    CGContextRef context = createCGContext(size.width, size.height);

    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);

    FIImage *result = getImageFromCGContext(context);

    releaseCGContext(context);

    return result;
}

#pragma mark flip

- (FIImage *)toFIImage:(CGImageRef)cg width:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    NSImage *image = [[FIImage alloc] initWithCGImage:cg size:size];

    CGImageRelease(cg);

    return image;
}

- (void)flip:(FIFlipOption *)option {
    BOOL h = option.horizontal;
    BOOL v = option.vertical;
    if (!h && !v) {
        return;
    }

    NSSize size = outImage.size;
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);

    CGContextRef ctx = createCGContext(size.width, size.height);

    CGImageRef cg = [outImage CGImage];

    CGContextClipToRect(ctx, rect);

    if (!v && h) {
        CGContextTranslateCTM(ctx, size.width, 0);
        CGContextScaleCTM(ctx, -1, 1);
    } else if (v && !h) {
        CGContextTranslateCTM(ctx, 0, size.height);
        CGContextScaleCTM(ctx, 1, -1);
    } else if (v && h) {
        CGContextRotateCTM(ctx, M_PI);
        CGContextTranslateCTM(ctx, -size.width, -size.height);
    }

    CGContextDrawImage(ctx, rect, cg);

    outImage = [self getImageWith:ctx];
    releaseCGContext(ctx);
}

#pragma mark clip

- (void)clip:(FIClipOption *)option {
    CGFloat w = option.width;
    CGFloat h = option.height;
    CGFloat x = option.x;
    CGFloat y = option.y;

    CGRect targetRect = CGRectMake(x, y, w, h);

    CGImageRef srcImage = [outImage CGImage];

    CGImageRef resultCg = CGImageCreateWithImageInRect(srcImage, targetRect);

    NSImage *image = [[NSImage alloc] initWithCGImage:resultCg size:NSMakeSize(w, h)];
    outImage = image;

    CGImageRelease(resultCg);
}

#pragma mark rotate

- (void)rotate:(FIRotateOption *)option {
    double degree = 360 - option.degree;
    CGFloat angle = [self convertDegreeToRadians:degree];
    CGSize oldSize = outImage.size;
    CGRect oldRect = CGRectMake(0, 0, oldSize.width, oldSize.height);
    CGAffineTransform aff = CGAffineTransformMakeRotation(angle);
    CGRect newRect = CGRectApplyAffineTransform(oldRect, aff);
    CGSize newSize = newRect.size;

    CGContextRef ctx = createCGContext((size_t) newSize.width, (size_t) newSize.height);

    if (!ctx) {
        return;
    }

    CGContextTranslateCTM(ctx, newSize.width / 2, newSize.height / 2);
    CGContextRotateCTM(ctx, angle);

    CGImageRef cg = [outImage CGImage];

    CGRect rect = CGRectMake(-oldSize.width / 2, -oldSize.height / 2, oldSize.width, oldSize.height);
    CGContextDrawImage(ctx, rect, cg);
    FIImage *newImage = [self getImageWith:ctx];
    releaseCGContext(ctx);

    if (!newImage) {
        return;
    }

    outImage = newImage;
}

- (CGFloat)convertDegreeToRadians:(CGFloat)degree {
    return degree * M_PI / 180;
}

#pragma mark color matrix


#pragma clang diagnostic push
#pragma ide diagnostic ignored "KeyValueCodingInspection"
- (void)colorMatrix:(FIColorOption *)option {
    if (!outImage) {
        return;
    }

    CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
    NSObject <CIColorMatrix> *matrix = (NSObject <CIColorMatrix> *) filter;

    [filter setDefaults];

    CIImage *inputCIImage = [outImage CIImage];
    NSLog(@"input size = %@", NSStringFromRect([inputCIImage extent]));
    [matrix setValue:inputCIImage forKey:kCIInputImageKey];
//    [matrix setRVector:[self getCIVector:option start:0]];
    [matrix setValue:[self getCIVector:option start:0] forKey:@"inputRVector"];
    [matrix setValue:[self getCIVector:option start:5] forKey:@"inputGVector"];
    [matrix setValue:[self getCIVector:option start:10] forKey:@"inputBVector"];
    [matrix setValue:[self getCIVector:option start:15] forKey:@"inputAVector"];
    [matrix setValue:[self getOffsetCIVector:option] forKey:@"inputBiasVector"];

    CIImage *outputCIImage = [matrix outputImage];

    if (!outputCIImage) {
        return;
    }

    CIContext *ctx = [[CIContext alloc] initWithOptions:@{}];
    CGImageRef cgImage = [ctx createCGImage:outputCIImage fromRect:[outputCIImage extent]];

    FIImage *newImage = [self toFIImage:cgImage width:outImage.size.width height:outImage.size.height];

    if (!newImage) {
        return;
    }

    outImage = newImage;
}
#pragma clang diagnostic pop

- (CIVector *)getCIVector:(FIColorOption *)option start:(NSUInteger)start {
    CGFloat v1 = [option getValue:start];
    CGFloat v2 = [option getValue:start + 1];
    CGFloat v3 = [option getValue:start + 2];
    CGFloat v4 = [option getValue:start + 3];
    return [CIVector vectorWithX:v1 Y:v2 Z:v3 W:v4];
}

- (CIVector *)getOffsetCIVector:(FIColorOption *)option {
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

    CGImageRef srcImage = outImage.CGImage;

    double width = option.width;
    double height = option.height;

    if (option.keepRatio) {
        CGSize srcSize = CGImageGetSize(srcImage);

        double srcRatio = srcSize.width / srcSize.height;

        if (option.keepWidthFirst) {
            height = width / srcRatio;
        } else {
            width = srcRatio * height;
        }
    }

    CGContextRef context = createCGContext((size_t) width, (size_t) height);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), srcImage);

    outImage = [self getImageWith:context];

    releaseCGContext(context);
}

#pragma mark add text

- (void)addText:(FIAddTextOption *)option {
    if (!outImage) {
        return;
    }

    if (option.texts.count == 0) {
        return;
    }

    CGContextRef ctx = createCGContext((size_t) outImage.size.width, (size_t) outImage.size.height);

    if (!ctx) {
        return;
    }

    CGContextDrawImage(ctx, CGRectMake(0, 0, outImage.size.width, outImage.size.height), [outImage CGImage]);

    for (FIAddText *text in option.texts) {
        NSColor *color = [NSColor colorWithRed:(text.r / 255.0) green:(text.g / 255.0) blue:(text.b / 255.0) alpha:(text.a / 255.0)];

        FIFont *font;

        if ([@"" isEqualToString:text.fontName]) {
            font = [FIFont systemFontOfSize:text.fontSizePx];
        } else {
            font = [FIFont fontWithName:text.fontName size:text.fontSizePx];
        }

        CGFloat w = outImage.size.width - text.x;
        CGFloat h = outImage.size.height - text.y;

        CGRect rect = CGRectMake(text.x, text.y, w, h);

        [self addTextWithContext:ctx text:text.text color:color rect:rect fontName:font.fontName textSize:text.fontSizePx];
    }

    NSImage *newImage = [self getImageWith:ctx];

    releaseCGContext(ctx);

    if (!newImage) {
        return;
    }

    outImage = newImage;
}

- (void)addTextWithContext:(CGContextRef)context text:(NSString *)text color:(NSColor *)color rect:(CGRect)range fontName:(NSString *)fontName textSize:(CGFloat)textSize {

    // Set the text matrix.
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();

    // In this simple example, initialize a rectangular path.
//    CGRect bounds = CGRectMake(10.0, 10.0, 200.0, 200.0);
    CGRect bounds = range;
    CGPathAddRect(path, NULL, bounds);

    // Initialize a string.
//    CFStringRef textString = CFSTR("Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine.");
    CFStringRef textString = (__bridge CFStringRef) text;

    // Create a mutable attributed string with a max length of 0.
    // The max length is a hint as to how much internal storage to reserve.
    // 0 means no hint.
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);

    // Copy the textString into the newly created attrString
    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0),
        textString);

    // Create a color that will be added as an attribute to the attrString.
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent};

    CGColorRef red = CGColorCreate(rgbColorSpace, components);
    CGColorSpaceRelease(rgbColorSpace);

    // Set font
    CFStringRef cfFontName = (__bridge CFStringRef) fontName;
    CTFontRef font = CTFontCreateWithName(cfFontName, textSize, nil);
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, text.length), kCTFontAttributeName, font);

    // Set the color of the first 12 chars to red.
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, text.length), kCTForegroundColorAttributeName, red);

    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);

    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);

    // Draw the specified frame in the given context.
    CTFrameDraw(frame, context);

    // Release the objects we used.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(font);

//    CFRelease(textString);
//    CFRelease(cfFontName);
}

#pragma mark mix image

- (void)mixImage:(FIMixImageOption *)option {
    if (!outImage) {
        return;
    }

    NSSize srcSize = outImage.size;

    CGRect srcRect = CGRectMake(0, 0, srcSize.width, srcSize.height);
    CGRect dstRect = CGRectMake(option.x, option.y, option.width, option.height);

    CGContextRef ctx = createCGContext((size_t) srcSize.width, (size_t) srcSize.height);

    if ([option.blendMode isEqualToNumber:@(kCGBlendModeDst)]) {

        CGContextDrawImage(ctx, dstRect, [outImage CGImage]);
    } else if ([option.blendMode isEqualToNumber:@(kCGBlendModeSrc)]) {
        NSImage *src = [[FIImage alloc] initWithData:option.src];
        CGContextDrawImage(ctx, srcRect, [src CGImage]);
    } else {
        CGContextDrawImage(ctx, dstRect, [outImage CGImage]);
        CGContextSetBlendMode(ctx, (CGBlendMode) [option.blendMode intValue]);
        NSImage *src = [[FIImage alloc] initWithData:option.src];
        CGContextDrawImage(ctx, srcRect, [src CGImage]);
    }

    FIImage *image = [self getImageWith:ctx];
    outImage = image;
    releaseCGContext(ctx);
}

#pragma mark "draw some thing"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
- (void)drawImage:(FIDrawOption *)option {
    if (!outImage) {
        return;
    }

    CGContextRef ctx = createCGContext((size_t) outImage.size.width, (size_t) outImage.size.height);
    if (!ctx) {
        return;
    }

//    [outImage drawInRect:CGRectMake(0, 0, outImage.size.width, outImage.size.height)];
    CGContextDrawImage(ctx, CGRectMake(0, 0, outImage.size.width, outImage.size.height), [outImage CGImage]);

    for (FIDrawPart *part in [option parts]) {
        if ([part isMemberOfClass:FILineDrawPart.class]) {
            [self draw:ctx line:(FILineDrawPart *) part];
        } else if ([part isMemberOfClass:FIOvalDrawPart.class]) {
            [self draw:ctx oval:(FIOvalDrawPart *) part];
        } else if ([part isMemberOfClass:FIRectDrawPart.class]) {
            [self draw:ctx rect:(FIRectDrawPart *) part];
        } else if ([part isMemberOfClass:FIPointsDrawPart.class]) {
            [self draw:ctx points:(FIPointsDrawPart *) part];
        } else if ([part isMemberOfClass:FIPathDrawPart.class]) {
            [self draw:ctx path:(FIPathDrawPart *) part];
        }

    }

    FIImage *newImage = [self getImageWith:ctx];
    releaseCGContext(ctx);

    if (!newImage) {
        return;
    }

    outImage = newImage;
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
- (void)draw:(CGContextRef)pContext path:(FIPathDrawPart *)path {
    NSArray<FIDrawPart *> *parts = [path parts];

    CGContextRef context = createCGContext((size_t) outImage.size.width, (size_t) outImage.size.height);

    for (FIDrawPart *part in parts) {
        if ([part isMemberOfClass:[FIPathMove class]]) {
            FIPathMove *move = (FIPathMove *) part;
            CGPoint point = move.offset;
            CGContextMoveToPoint(context, point.x, point.y);

        } else if ([part isMemberOfClass:[FIPathLine class]]) {
            FIPathLine *line = (FIPathLine *) part;
            CGPoint point = line.offset;
            CGContextAddLineToPoint(context, point.x, point.y);
        } else if ([part isMemberOfClass:[FIPathArc class]]) {
            FIPathArc *arc = (FIPathArc *) part;
            CGRect rect = [arc rect];
            CGPoint point = rect.origin;
            CGFloat start = [arc start];
            CGFloat sweep = [arc sweep];
            CGFloat end = start + sweep;
            BOOL closeWise = [arc useCenter];

            CGPoint center = CGPointMake(point.x + rect.size.width / 2, point.y + rect.size.height / 2);
//            // TODO: fix: calc radius
            CGContextAddArc(context, center.x, center.y, 1, start, end, closeWise);
        } else if ([part isMemberOfClass:[FIPathBezier class]]) {
            FIPathBezier *bezier = (FIPathBezier *) part;

            int kind = [bezier kind];
            CGPoint point = [bezier target];
            CGPoint c1 = [bezier control1];
            if (kind == 2) {
                CGContextAddQuadCurveToPoint(context, c1.x, c1.y, point.x, point.y);
            } else if (kind == 3) {
                CGPoint c2 = [bezier control2];
                CGContextAddCurveToPoint(context, c1.x, c1.y, c2.x, c2.y, point.x, point.y);
            }
        }

    }

    if ([path autoClose]) {
        CGContextClosePath(context);
    }

    [self drawWithPaint:pContext paint:[path paint]];

    CGPathDrawingMode mode;
    if ([path paint].fill) {
        mode = kCGPathFill;
    } else {
        mode = kCGPathStroke;
    }
    CGContextDrawPath(pContext, mode);

    outImage = [self getImageWith:context];
    releaseCGContext(context);
}
#pragma clang diagnostic pop

#endif

#if TARGET_OS_IOS
- (NSData *)outputMemory {
  FIFormatOption *fmt = self.optionGroup.fmt;
  if (fmt.format == 0) {
    return UIImagePNGRepresentation(outImage);
  } else {
    return UIImageJPEGRepresentation(outImage, ((CGFloat) fmt.quality) / 100);
  }
}

+ (FIImage *)fixImageOrientation:(FIImage *)image {
  UIImageOrientation or = image.imageOrientation;
  if (or == UIImageOrientationUp) {
    return image;
  }

  UIGraphicsBeginImageContext(image.size);

  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];

  FIImage *result = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  if (!result) {
    return image;
  } else {
    return result;
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

  FIImage *result = UIGraphicsGetImageFromCurrentImageContext();

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
  CGImageRelease(resultCg);
}

#pragma mark rotate

- (void)rotate:(FIRotateOption *)option {
  CGFloat redians = [self convertDegreeToRadians:option.degree];
  CGSize oldSize = outImage.size;
  CGRect oldRect = CGRectMake(0, 0, oldSize.width, oldSize.height);
  CGAffineTransform aff = CGAffineTransformMakeRotation(redians);
  CGRect newRect = CGRectApplyAffineTransform(oldRect, aff);
  CGSize newSize = newRect.size;

  UIGraphicsBeginImageContext(newSize);

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
  NSObject <CIColorMatrix> *matrix = (NSObject <CIColorMatrix> *) filter;

  [filter setDefaults];

  CIImage *inputCIImage = [[CIImage alloc] initWithImage:outImage options:nil];
  NSLog(@"input size = %@", NSStringFromCGRect([inputCIImage extent]));
  [matrix setValue:inputCIImage forKey:kCIInputImageKey];
//    [matrix setRVector:[self getCIVector:option start:0]];
  [matrix setValue:[self getCIVector:option start:0] forKey:@"inputRVector"];
  [matrix setValue:[self getCIVector:option start:5] forKey:@"inputGVector"];
  [matrix setValue:[self getCIVector:option start:10] forKey:@"inputBVector"];
  [matrix setValue:[self getCIVector:option start:15] forKey:@"inputAVector"];
  [matrix setValue:[self getOffsetCIVector:option] forKey:@"inputBiasVector"];

  CIImage *outputCIImage = [matrix outputImage];

  if (!outputCIImage) {
    return;
  }

  CIContext *ctx = [CIContext contextWithOptions:nil];
  CGImageRef cgImage = [ctx createCGImage:outputCIImage fromRect:[outputCIImage extent]];

  FIImage *newImage = [UIImage imageWithCGImage:cgImage];

  if (!newImage) {
    return;
  }

  outImage = newImage;
}

- (CIVector *)getCIVector:(FIColorOption *)option start:(int)start {
  CGFloat v1 = [option getValue:start];
  CGFloat v2 = [option getValue:start + 1];
  CGFloat v3 = [option getValue:start + 2];
  CGFloat v4 = [option getValue:start + 3];
  return [CIVector vectorWithX:v1 Y:v2 Z:v3 W:v4];
}

- (CIVector *)getOffsetCIVector:(FIColorOption *)option {
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

  UIGraphicsBeginImageContext(CGSizeMake(option.width, option.height));

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  [outImage drawInRect:CGRectMake(0, 0, option.width, option.height)];

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  if (!newImage) {
    return;
  }

  outImage = newImage;
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
    UIColor *color = [UIColor colorWithRed:(text.r / 255.0) green:(text.g / 255.0) blue:(text.b / 255.0) alpha:(text.a / 255.0)];

    UIFont *font;

      if ([@"" isEqualToString: text.fontName ]){
        font = [UIFont systemFontOfSize:text.fontSizePx];
      }else{
          font = [UIFont fontWithName:text.fontName size:text.fontSizePx];
      }


    NSDictionary *attr = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSBackgroundColorAttributeName: UIColor.clearColor,
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

#pragma mark "draw some thing"

- (void)draw:(CGContextRef)ctx bezier:(FIBezierPath *)bezier paint:(FIPaint *)paint {
  CGMutablePathRef path = CGPathCreateMutable();
//  UIColor *color = paint.color;
  if (paint.fill) {
//    [bezier fill];
//    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetRGBFillColor(ctx, [paint r], [paint g], [paint b], [paint a]);
    CGContextSetLineWidth(ctx, paint.paintWeight);
    CGPathAddPath(path, nil, [bezier CGPath]);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextFillPath(ctx);
  } else {
//    [bezier stroke];
//    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetRGBStrokeColor(ctx, [paint r], [paint g], [paint b], [paint a]);
    CGContextSetLineWidth(ctx, paint.paintWeight);
    CGPathAddPath(path, nil, [bezier CGPath]);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextStrokePath(ctx);
  }

  CGPathRelease(path);
}

- (void)drawImage:(FIDrawOption *)option {
  if (!outImage) {
    return;
  }

  UIGraphicsBeginImageContext(outImage.size);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  if (!ctx) {
    return;
  }

  [outImage drawInRect:CGRectMake(0, 0, outImage.size.width, outImage.size.height)];

  for (FIDrawPart *part in [option parts]) {
    if ([part isMemberOfClass:FILineDrawPart.class]) {
      [self draw:ctx line:(FILineDrawPart *) part];
    } else if ([part isMemberOfClass:FIOvalDrawPart.class]) {
      [self draw:ctx oval:(FIOvalDrawPart *) part];
    } else if ([part isMemberOfClass:FIRectDrawPart.class]) {
      [self draw:ctx rect:(FIRectDrawPart *) part];
    } else if ([part isMemberOfClass:FIPointsDrawPart.class]) {
      [self draw:ctx points:(FIPointsDrawPart *) part];
    } else if ([part isMemberOfClass:FIPathDrawPart.class]) {
      [self draw:ctx path:(FIPathDrawPart *) part];
    }

  }

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();
  if (!newImage) {
    return;
  }

  outImage = newImage;
}

- (void)draw:(CGContextRef)pContext path:(FIPathDrawPart *)path {
  NSArray<FIDrawPart *> *parts = [path parts];

  FIBezierPath *bezierPath = [FIBezierPath bezierPath];

  for (FIDrawPart *part in parts) {
    if ([part isMemberOfClass:[FIPathMove class]]) {
      FIPathMove *move = (FIPathMove *) part;
      [bezierPath moveToPoint:[move offset]];
    } else if ([part isMemberOfClass:[FIPathLine class]]) {
      FIPathLine *line = (FIPathLine *) part;
      [bezierPath addLineToPoint:[line offset]];
    } else if ([part isMemberOfClass:[FIPathArc class]]) {
      FIPathArc *arc = (FIPathArc *) part;
      CGRect rect = [arc rect];
      CGPoint point = rect.origin;
      CGFloat start = [arc start];
      CGFloat sweep = [arc sweep];
      CGFloat end = start + sweep;
      BOOL closeWise = [arc useCenter];

      CGPoint center = CGPointMake(point.x + rect.size.width / 2, point.y + rect.size.height / 2);
      // TODO: fix: calc radius
      [bezierPath addArcWithCenter:center radius:1 startAngle:start endAngle:end clockwise:closeWise];
    } else if ([part isMemberOfClass:[FIPathBezier class]]) {
      FIPathBezier *bezier = (FIPathBezier *) part;

      int kind = [bezier kind];
      CGPoint point = [bezier target];
      CGPoint c1 = [bezier control1];
      if (kind == 2) {
        [bezierPath addQuadCurveToPoint:point controlPoint:c1];
      } else if (kind == 3) {
        CGPoint c2 = [bezier control2];
        [bezierPath addCurveToPoint:point controlPoint1:c1 controlPoint2:c2];
      }
    }

  }

  if ([path autoClose]) {
    [bezierPath closePath];
  }

  [self drawWithPaint:pContext paint:[path paint]];

  CGPathRef pPath = [bezierPath CGPath];
  CGContextAddPath(pContext, pPath);
  CGPathDrawingMode mode;
  if ([path paint].fill) {
    mode = kCGPathFill;
  } else {
    mode = kCGPathStroke;
  }
  CGContextDrawPath(pContext, mode);
}

#endif


- (void)draw:(CGContextRef)pContext points:(FIPointsDrawPart *)points {
    FIPaint *paint = [points paint];
    paint.fill = YES;
    int weight = paint.paintWeight;

    for (NSArray *value in [points points]) {
        CGPoint point = [FICommonUtils arrayToPoint:value];
        CGRect rect = CGRectMake(point.x - weight / 2, point.y - weight / 2, weight, weight);
        CGContextAddEllipseInRect(pContext, rect);
    }
    [self drawWithPaint:pContext paint:paint];
}

- (void)draw:(CGContextRef)pContext rect:(FIRectDrawPart *)rect {
    CGContextAddRect(pContext, [rect rect]);
    [self drawWithPaint:pContext paint:[rect paint]];
}

- (void)draw:(CGContextRef)pContext oval:(FIOvalDrawPart *)oval {
    CGContextAddEllipseInRect(pContext, [oval rect]);
    [self drawWithPaint:pContext paint:[oval paint]];
}

- (void)draw:(CGContextRef)pContext line:(FILineDrawPart *)line {
    CGPoint start = [line start];
    const CGPoint anEnd = [line end];
    CGContextMoveToPoint(pContext, start.x, start.y);
    CGContextAddLineToPoint(pContext, anEnd.x, anEnd.y);
    [self drawWithPaint:pContext paint:[line paint]];
}

- (void)drawWithPaint:(CGContextRef)ctx paint:(FIPaint *)paint {
    CGContextSetLineWidth(ctx, paint.paintWeight);
    if (paint.fill) {
        CGContextSetRGBFillColor(ctx, [paint r], [paint g], [paint b], [paint a]);
        CGContextFillPath(ctx);
    } else {
        CGContextSetRGBStrokeColor(ctx, [paint r], [paint g], [paint b], [paint a]);
        CGContextStrokePath(ctx);
    }
}

@end
