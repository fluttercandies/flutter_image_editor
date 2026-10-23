//
//  FIEPlugin.m
//  image_editor
//
//  Created by Caijinglong on 2020/5/22.
//

#import "FIEPlugin.h"
#import "FIConvertUtils.h"
#import "FIMerger.h"
#import "FIUIImageHandler.h"

typedef void (^FontBlock)(FIFont *font,NSString* name);
typedef void (^VoidBlock)(void);

@implementation FIEPlugin {
  dispatch_queue_global_t _queue;
}

+ (void)registerWithRegistrar:
    (nonnull NSObject<FlutterPluginRegistrar> *)registrar {
  FIEPlugin *plugin = [FIEPlugin new];
  [plugin initQueue];
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"com.fluttercandies/image_editor"
            binaryMessenger:registrar.messenger];

  [registrar addMethodCallDelegate:plugin channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
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
  } else if ([method isEqualToString:@"mergeToMemory"]) {
    [self handleMerge:args outMemory:YES result:result];
  } else if ([method isEqualToString:@"mergeToFile"]) {
    [self handleMerge:args outMemory:NO result:result];
  } else if ([method isEqualToString:@"registerFont"]) {
    [self asyncExec:^{
      NSString *path = args[@"path"];
      NSData *data = [NSData dataWithContentsOfFile:path];
      [self registerFontWithData:data block:^(FIFont *font, NSString *name) {
        result(name);
      }];
    }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)initQueue {
  _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)asyncExec:(VoidBlock)block {
  dispatch_async(_queue, ^(){
      @autoreleasepool {
          block();
      }
  });
}

- (void)handleMerge:(id)args
          outMemory:(BOOL)outMemory
             result:(FlutterResult)result {
  [self asyncExec:^{
    FIMerger *merger = [FIMerger new];
    merger.option = [FIMergeOption createFromDict:args[@"option"]];
    NSData *data = [merger process];

    if (!data) {
      result([FlutterError errorWithCode:@"cannot merge image"
                                 message:nil
                                 details:nil]);
      return;
    }

    if (outMemory) {
      dispatch_async(dispatch_get_main_queue(), ^{
        result(data);
      });
    } else {
      NSString *filePath = [merger makeOutputPath];
      [data writeToFile:filePath atomically:YES];
      dispatch_async(dispatch_get_main_queue(), ^{
        result(filePath);
      });
    }
  }];
}

- (void)handleArgs:(id)args
         outMemory:(BOOL)outMemory
            result:(FlutterResult)result {
  [self asyncExec:^{
    FIImage *image = [self getUIImage:args];
    if (!image) {
      dispatch_async(dispatch_get_main_queue(), ^{
        result([FlutterError errorWithCode:@"decode image error"
                                   message:nil
                                   details:nil]);
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
    if (outMemory) {
      NSData *data = [handler outputMemory];
      dispatch_async(dispatch_get_main_queue(), ^{
        result(data);
      });
    } else {
      NSString *target = args[@"target"];
      BOOL success = [handler outputFile:target];
      dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
          result(target);
        } else {
          result([FlutterError errorWithCode:@"cannot handle"
                                     message:nil
                                     details:nil]);
        }
      });
    }
  }];
}

- (FIImage *)getUIImage:(id)args {
  NSDictionary *dict = args;
  NSString *path = dict[@"src"];
  if (path) {
    NSURL *url = [NSURL URLWithString:path];
    if (!url) {
      return nil;
    }

#if TARGET_OS_IOS

    return [FIImage imageWithContentsOfFile:url.absoluteString];
#endif

#if TARGET_OS_OSX
    return [[FIImage alloc] initWithContentsOfFile:url.absoluteString];
#endif
  }

  FlutterStandardTypedData *fData = dict[@"image"];
  if (!fData) {
    return nil;
  }

  NSData *data = fData.data;
  if (!data) {
    return nil;
  }
#if TARGET_OS_IOS
  return [FIImage imageWithData:data];
#endif

#if TARGET_OS_OSX
  return [[FIImage alloc] initWithData:data];
#endif
}

- (void)registerFontWithData:(NSData *)data block:(FontBlock)block {

  CFErrorRef error;
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  CGFontRef font = CGFontCreateWithDataProvider(provider);
  NSString *name =
      (NSString *)CFBridgingRelease(CGFontCopyPostScriptName(font));

  if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
    CFStringRef errorDescription = CFErrorCopyDescription(error);
    NSLog(@"Failed to load font: %@", errorDescription);
    CFRelease(errorDescription);
  } else {
    NSLog(@"register font success : %@", name);
  }
  FIFont *uiFont = [FIFont fontWithName:name size:14];
  CFRelease(font);
  CFRelease(provider);
  block(uiFont, name);
}

@end
