#import "FlutterImageEditorPlugin.h"
#import <image_editor/image_editor-Swift.h>
#import "oc/FIEPlugin.h"

@implementation FlutterImageEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  //  [SwiftFlutterImageEditorPlugin registerWithRegistrar:registrar];
  [FIEPlugin registerWithRegistrar:registrar];
}

@end
