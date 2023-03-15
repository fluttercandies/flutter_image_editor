import 'package:flutter_test/flutter_test.dart';
import 'package:image_editor_platform_interface/src/option/edit_options.dart';

void main() {
  test('contrast = 1 should give us the default matrix', () {
    expect(ColorOption.contrast(1).matrix, defaultColorMatrix);
  });
  test(
    'contrast = 0 should have zeros in the diameter, '
    '127.5 in last column except for the last row',
    () {
      final matrix = List.filled(defaultColorMatrix.length, 0.0);
      matrix[4] = 127.5;
      matrix[9] = 127.5;
      matrix[14] = 127.5;
      matrix[18] = 1;
      expect(ColorOption.contrast(0).matrix, matrix);
    },
  );
}
