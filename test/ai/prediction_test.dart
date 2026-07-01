import 'package:flutter_test/flutter_test.dart';

import 'package:agrisucces/ai/model/prediction.dart';

void main() {
  group('Prediction', () {
    final prediction = Prediction(
      crop: 'Tomate',
      disease: 'Alternariose',
      confidence: 0.92,
      diseaseKey: 'tomato_early_blight',
      date: DateTime(2026, 6, 29, 12, 0),
    );

    test('serializes and deserializes to JSON', () {
      final json = prediction.toJson();
      final restored = Prediction.fromJson(json);

      expect(restored.crop, prediction.crop);
      expect(restored.disease, prediction.disease);
      expect(restored.confidence, prediction.confidence);
      expect(restored.diseaseKey, prediction.diseaseKey);
      expect(restored.date, prediction.date);
    });

    test('copyWith creates modified copy', () {
      final copy = prediction.copyWith(confidence: 0.99);

      expect(copy.confidence, 0.99);
      expect(copy.crop, prediction.crop);
    });
  });
}
