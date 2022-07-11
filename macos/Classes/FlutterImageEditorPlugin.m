#import "FlutterImageEditorPlugin.h"
#import "FIEPlugin.h"

@implementation FlutterImageEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [FIEPlugin registerWithRegistrar:registrar];
}

@end
