//
//  FIUIImageHandler.m
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "EditorUIImageHandler.h"
#import <CoreImage/CIFilterBuiltins.h>


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

UIImage *getImageFromCGContext(CGContextRef context) {
    size_t h = CGBitmapContextGetHeight(context);
    size_t w = CGBitmapContextGetWidth(context);

    CGImageRef pImage = CGBitmapContextCreateImage(context);

    UIImage *image = [[UIImage alloc] initWithCGImage:pImage];
    CGImageRelease(pImage);
    return image;
}


@implementation EditorUIImageHandler {
    UIImage *outImage;
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

- (NSData *)outputMemory {
    FIFormatOption *fmt = self.optionGroup.fmt;
    if (fmt.format == 0) {
        return UIImagePNGRepresentation(outImage);
    } else {
        return UIImageJPEGRepresentation(outImage, ((CGFloat) fmt.quality) / 100);
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
    outImage = [EditorUIImageHandler fixImageOrientation:outImage];
}

#pragma mark flip

- (void)flip:(FIFlipOption *)option {
    BOOL h = option.horizontal;
    BOOL v = option.vertical;
    if (!h && !v) {
        return;
    }
    CGSize size = outImage.size;
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
    CGImageRelease(resultCg);
}

#pragma mark rotate

- (void)rotate:(FIRotateOption *)option {
    CGFloat radians = [self convertDegreeToRadians:option.degree];
    CGSize oldSize = outImage.size;
    CGRect oldRect = CGRectMake(0, 0, oldSize.width, oldSize.height);
    CGAffineTransform aff = CGAffineTransformMakeRotation(radians);
    CGRect newRect = CGRectApplyAffineTransform(oldRect, aff);
    CGSize newSize = newRect.size;
    UIGraphicsBeginImageContext(newSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }
    CGContextTranslateCTM(ctx, newSize.width / 2, newSize.height / 2);
    CGContextRotateCTM(ctx, radians);
    [outImage drawInRect:CGRectMake(-oldSize.width / 2, -oldSize.height / 2, oldSize.width, oldSize.height)];
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
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
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

    outImage = getImageFromCGContext(context);

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
    UIGraphicsBeginImageContext(outImage.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }
    [outImage drawInRect:CGRectMake(0, 0, outImage.size.width, outImage.size.height)];
    for (FIAddText *text in option.texts) {
        UIColor *color = [UIColor colorWithRed:(text.r / 255.0)
                                         green:(text.g / 255.0)
                                          blue:(text.b / 255.0)
                                         alpha:(text.a / 255.0)];
        UIFont *font;
        if ([@"" isEqualToString: text.fontName]){
            font = [UIFont systemFontOfSize:text.fontSizePx];
        } else {
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
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
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

- (void)draw:(CGContextRef)pContext points:(FIPointsDrawPart *)points {
    FIPaint *paint = [points paint];
    paint.fill = YES;
    int weight = paint.paintWeight;
    for (NSValue *value in [points points]) {
        CGPoint point = [value CGPointValue];
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

- (void)draw:(CGContextRef)ctx bezier:(UIBezierPath *)bezier paint:(FIPaint *)paint {
    CGMutablePathRef path = CGPathCreateMutable();
    if (paint.fill) {
        CGContextSetRGBFillColor(ctx, [paint r], [paint g], [paint b], [paint a]);
        CGContextSetLineWidth(ctx, paint.paintWeight);
        CGPathAddPath(path, nil, [bezier CGPath]);
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextFillPath(ctx);
    } else {
        CGContextSetRGBStrokeColor(ctx, [paint r], [paint g], [paint b], [paint a]);
        CGContextSetLineWidth(ctx, paint.paintWeight);
        CGPathAddPath(path, nil, [bezier CGPath]);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextStrokePath(ctx);
    }
    CGPathRelease(path);
}

@end
