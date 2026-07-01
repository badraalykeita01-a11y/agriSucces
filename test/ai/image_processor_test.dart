import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agrisucces/ai/exceptions/ai_exceptions.dart';
import 'package:agrisucces/ai/utils/image_processor.dart';

Uint8List _createTestPng({int width = 10, int height = 10}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(100, 150, 50));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('ImageProcessor', () {
    final processor = ImageProcessor();

    test('throws InvalidImageException for empty bytes', () {
      expect(
        () => processor.preprocessFromBytes(Uint8List(0)),
        throwsA(isA<InvalidImageException>()),
      );
    });

    test('throws InvalidImageException for invalid image bytes', () {
      expect(
        () => processor.preprocessFromBytes(Uint8List.fromList([1, 2, 3, 4])),
        throwsA(isA<InvalidImageException>()),
      );
    });

    test('produces tensor with correct shape for valid PNG', () {
      final tensor = processor.preprocessFromBytes(_createTestPng());

      expect(tensor.length, 1);
      expect(tensor[0].length, 224);
      expect(tensor[0][0].length, 224);
      expect(tensor[0][0][0].length, 3);
    });
  });
}
