import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../image_source.dart';
import '../output_format.dart';
import '../utils/convert_utils.dart';

part 'add_text.dart';
part 'clip.dart';
part 'color.dart';
part 'draw.dart';
part 'flip.dart';
part 'mix_image.dart';
part 'rotate.dart';
part 'scale.dart';

/// Used to describe whether it can be ignored.
abstract class IgnoreAble {
  /// Whether it is ture, it can be ignored.
  bool get canIgnore;
}

/// Used to describe whether transmission is possible.
abstract class TransferValue implements IgnoreAble {
  /// Used to describe whether transmission is possible.
  const TransferValue();

  /// The key of transfer value.
  String get key;

  /// The value of transfer value.
  Map<String, Object> get transferValue;
}

/// All options are subclasses of it.
abstract class Option implements IgnoreAble, TransferValue {
  const Option();
}

/// Used to describe editing options.
class ImageEditorOption implements IgnoreAble {
  ImageEditorOption();

  /// All option groups
  final List<OptionGroup> groupList = [];

  /// Output format for result image.
  OutputFormat outputFormat = const OutputFormat.jpeg(95);

  /// Expand [groupList] to [List]
  List<Option> get options {
    List<Option> result = [];
    for (final group in groupList) {
      for (final opt in group) {
        result.add(opt);
      }
    }
    return result;
  }

  /// Clear all options.
  void reset() {
    groupList.clear();
  }

  /// Add a [option] to [groupList].
  ///
  /// If [newGroup] is true, it will create a new group.
  void addOption(Option option, {bool newGroup = false}) {
    final OptionGroup group;
    if (groupList.isEmpty || newGroup) {
      group = OptionGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }
    group.addOption(option);
  }

  /// Add all of [options] to [groupList].
  ///
  /// If [newGroup] is true, it will create a new group.
  void addOptions(List<Option> options, {bool newGroup = true}) {
    final OptionGroup group;
    if (groupList.isEmpty || newGroup) {
      group = OptionGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }
    group.addOptions(options);
  }

  /// Convert current to [Map]
  List<Map<String, Object>> toJson() {
    return <Map<String, Object>>[
      for (final option in options)
        if (!option.canIgnore)
          {'type': option.key, 'value': option.transferValue},
    ];
  }

  @override
  bool get canIgnore {
    for (final opt in options) {
      if (!opt.canIgnore) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'options': toJson(),
      'fmt': outputFormat.toJson(),
    });
  }
}

class OptionGroup extends ListBase<Option> implements IgnoreAble {
  @override
  bool get canIgnore {
    return !options.any((Option e) => !e.canIgnore);
  }

  final List<Option> options = [];

  void addOption(Option option) {
    options.add(option);
  }

  void addOptions(List<Option> optionList) {
    options.addAll(optionList);
  }

  @override
  int get length => options.length;

  @override
  Option operator [](int index) {
    return options[index];
  }

  @override
  void operator []=(int index, value) {
    options[index] = value;
  }

  @override
  set length(int newLength) {
    options.length = newLength;
  }
}
