import 'package:flutter/services.dart';

/// Used to describe fields that can be JSON,
/// mainly used for [MethodChannel] invoke.
mixin JsonAble {
  /// Convert current instance to [Map].
  Map<String, Object?> toJson();
}
