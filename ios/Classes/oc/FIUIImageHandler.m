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
}

- (void)outputFile:(NSString *)targetPath {
  NSData *data = [self outputMemory];
  if (!data) {
    return;
  }
  NSURL *url = [NSURL URLWithString:targetPath];
  [data writeToURL:url atomically:YES];
}

- (NSData *)outputMemory {
  FIFormatOption *fmt = self.optionGroup.fmt;
  if (fmt.format == 0) {
    return UIImagePNGRepresentation(outImage);
  } else {
    return UIImageJPEGRepresentation(outImage, ((CGFloat)fmt.quality) / 100);
  }
}

@end
