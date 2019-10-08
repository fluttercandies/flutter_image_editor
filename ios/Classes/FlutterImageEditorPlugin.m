#import "FlutterImageEditorPlugin.h"
#import <flutter_image_editor/flutter_image_editor-Swift.h>

@implementation FlutterImageEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterImageEditorPlugin registerWithRegistrar:registrar];
}
@end
