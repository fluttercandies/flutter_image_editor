import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/src/image_source.dart';
import 'package:image_editor/src/utils/convert_utils.dart';

import '../output_format.dart';

part 'flip.dart';

part 'clip.dart';

part 'rotate.dart';

part 'color.dart';

part 'scale.dart';

part 'add_text.dart';

part 'mix_image.dart';

part 'draw.dart';

abstract class IgnoreAble {
  bool get canIgnore;
}

abstract class TransferValue implements IgnoreAble {
  const TransferValue();

  String get key;

  Map<String, Object> get transferValue;
}

abstract class Option implements IgnoreAble, TransferValue {
  const Option();
}

class ImageEditorOption implements IgnoreAble {
  ImageEditorOption();

  final List<OptionGroup> groupList = [];
  OutputFormat outputFormat = const OutputFormat.jpeg(95);

  List<Option> get options {
    List<Option> result = [];
    for (final group in groupList) {
      for (final opt in group) {
        result.add(opt);
      }
    }
    return result;
  }

  void reset() {
    groupList.clear();
  }

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
