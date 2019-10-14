import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'dart:math' show pi;

import 'package:image_editor/image_editor.dart';

abstract class IgnoreAble {
  bool get canIgnore;
}

abstract class Option implements IgnoreAble {
  String get key;

  Map<String, dynamic> get transferValue;
}

class ImageEditorOption implements IgnoreAble {
  ImageEditorOption();

  OutputFormat outputFormat = OutputFormat.jpeg(95);

  List<Option> get options {
    List<Option> result = [];
    for (final group in groupList) {
      for (final opt in group) {
        result.add(opt);
      }
    }
    return result;
  }

  List<OptionGroup> groupList = [];

  void reset() {
    groupList.clear();
  }

  void addOption(Option option, {bool newGroup = false}) {
    OptionGroup group;
    if (groupList.isEmpty || newGroup) {
      group = OptionGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }

    group.addOption(option);
  }

  void addOptions(List<Option> options, {bool newGroup = true}) {
    OptionGroup group;
    if (groupList.isEmpty || newGroup) {
      group = OptionGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }

    group.addOptions(options);
  }

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> result = [];
    for (final option in options) {
      if (option.canIgnore) {
        continue;
      }
      result.add({
        "type": option.key,
        "value": option.transferValue,
      });
    }
    return result;
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
}

class OptionGroup extends ListBase<Option> implements IgnoreAble {
  @override
  bool get canIgnore {
    for (final option in options) {
      if (!option.canIgnore) {
        return false;
      }
    }
    return true;
  }

  final List<Option> options = [];

  void addOptions(List<Option> optionList) {
    this.options.addAll(optionList);
  }

  void addOption(Option option) {
    this.options.add(option);
  }

  @override
  int get length => options.length;

  @override
  operator [](int index) {
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

class FlipOption implements Option {
  final bool horizontal;
  final bool vertical;

  FlipOption({
    this.horizontal = true,
    this.vertical = false,
  });

  @override
  String get key => "flip";

  @override
  Map<String, dynamic> get transferValue => {
        'h': horizontal,
        'v': vertical,
      };

  @override
  bool get canIgnore => horizontal == null || vertical == null;
}

class ClipOption implements Option {
  final num x;
  final num y;
  final num width;
  final num height;

  ClipOption({
    this.x = 0,
    this.y = 0,
    @required this.width,
    @required this.height,
  })  : assert(width > 0 && height > 0),
        assert(x >= 0, y >= 0);

  factory ClipOption.fromRect(Rect rect) {
    return ClipOption(
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  factory ClipOption.fromOffset(Offset start, Offset end) {
    return ClipOption(
      x: start.dx,
      y: start.dy,
      width: end.dx - start.dx,
      height: end.dy - start.dy,
    );
  }

  @override
  String get key => "clip";

  @override
  Map<String, dynamic> get transferValue => {
        "x": x.round(),
        "y": y.round(),
        "width": width.round(),
        "height": height.round(),
      };

  @override
  bool get canIgnore => width <= 0 || height <= 0;
}

class RotateOption implements Option {
  final int degree;

  RotateOption(this.degree);

  RotateOption.radian(double radian) : degree = (radian / pi * 180).toInt();

  @override
  String get key => "rotate";

  @override
  Map<String, dynamic> get transferValue => {
        "degree": degree,
      };

  @override
  bool get canIgnore => degree % 360 == 0;
}
