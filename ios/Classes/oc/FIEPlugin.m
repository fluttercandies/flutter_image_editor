//
//  FIEPlugin.m
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIEPlugin.h"
#import "FIConvertUtils.h"
#import "FIUIImageHandler.h"

@implementation FIEPlugin

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
  FIEPlugin *plugin = [FIEPlugin new];
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"top.kikt/flutter_image_editor"
                                  binaryMessenger:registrar.messenger];

  [registrar addMethodCallDelegate:plugin channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *method = call.method;
  id args = call.arguments;
  if ([method isEqualToString:@"getCachePath"]) {
    result(NSTemporaryDirectory());
  } else if ([method isEqualToString:@"memoryToFile"]) {
    [self handleArgs:args outMemory:NO result:result];
  } else if ([method isEqualToString:@"memoryToMemory"]) {
    [self handleArgs:args outMemory:YES result:result];
  } else if ([method isEqualToString:@"fileToMemory"]) {
    [self handleArgs:args outMemory:YES result:result];
  } else if ([method isEqualToString:@"fileToFile"]) {
    [self handleArgs:args outMemory:NO result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleArgs:(id)args outMemory:(BOOL)outMemory result:(FlutterResult)result {
  dispatch_queue_global_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    UIImage *image = [self getUIImage:args];
    if (!image) {
      dispatch_async(dispatch_get_main_queue(), ^{
        result([FlutterError errorWithCode:@"decode image error" message:nil details:nil]);
      });
      return;
    }

    NSDictionary *dict = args;
    NSArray *optionArray = dict[@"options"];
    FIEditorOptionGroup *optionGroup = [FIConvertUtils getOptions:optionArray];
    optionGroup.fmt = [FIFormatOption createFromDict:dict[@"fmt"]];

    FIUIImageHandler *handler = [FIUIImageHandler new];
    handler.image = image;
    handler.optionGroup = optionGroup;

    [handler handleImage];
  });
}

- (UIImage *)getUIImage:(id)args {
  NSDictionary *dict = args;
  NSString *path = dict[@"src"];
  if (path) {
    NSURL *url = [NSURL URLWithString:path];
    if (!url) {
      return nil;
    }
    return [UIImage imageWithContentsOfFile:url.absoluteString];
  }

  FlutterStandardTypedData *fData = dict[@"image"];
  if (!fData) {
    return nil;
  }

  NSData *data = fData.data;
  if (!data) {
    return nil;
  }

  return [UIImage imageWithData:data];
}

@end
