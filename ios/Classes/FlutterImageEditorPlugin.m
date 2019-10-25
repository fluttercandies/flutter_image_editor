#import "FlutterImageEditorPlugin.h"
#import <image_editor/image_editor-Swift.h>

@implementation FlutterImageEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterImageEditorPlugin registerWithRegistrar:registrar];
}

@end
