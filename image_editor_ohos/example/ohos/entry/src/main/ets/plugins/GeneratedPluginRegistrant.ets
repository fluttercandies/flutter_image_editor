import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import ImageEditorOhosPlugin from '@ohos/image_editor_ohos'
import ImagePickerPlugin from '@ohos/image_picker_ohos'
import PathProviderPlugin from '@ohos/path_provider_ohos'

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Ohos platform.
 */

const TAG = "GeneratedPluginRegistrant";

export class GeneratedPluginRegistrant {

  static registerWith(flutterEngine: FlutterEngine) {
    try {
      flutterEngine.getPlugins()?.add(new ImageEditorOhosPlugin());
      flutterEngine.getPlugins()?.add(new ImagePickerPlugin());
      flutterEngine.getPlugins()?.add(new PathProviderPlugin());
    } catch (e) {
      Log.e(
        TAG,
        "Tried to register plugins with FlutterEngine ("
          + flutterEngine
          + ") failed.");
      Log.e(TAG, "Received exception while registering", e);
    }
  }
}
