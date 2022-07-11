#import "ImageEditorPlugin.h"
#import "FIEPlugin.h"

@implementation ImageEditorPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [FIEPlugin registerWithRegistrar:registrar];
}

@end
