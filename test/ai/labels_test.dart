import 'package:flutter_test/flutter_test.dart';

import 'package:agrisucces/ai/labels/labels.dart';

void main() {
  group('Labels', () {
    const rawLabels = '''
Tomato___Early_blight
Tomato___healthy
Potato___Late_blight
''';

    test('parse labels and map to French display names', () {
      final labels = Labels.load(rawLabels);

      expect(labels.length, 3);

      final entry = labels.at(0);
      expect(entry.rawLabel, 'Tomato___Early_blight');
      expect(entry.crop, 'Tomato');
      expect(entry.disease, 'Early_blight');
      expect(entry.diseaseKey, 'tomato_early_blight');
      expect(entry.displayCrop, 'Tomate');
      expect(entry.displayDisease, 'Alternariose');
    });

    test('healthy label maps correctly', () {
      final labels = Labels.load(rawLabels);
      final healthy = labels.at(1);

      expect(healthy.diseaseKey, 'tomato_healthy');
      expect(healthy.displayDisease, 'Plante saine');
    });

    test('throws when index is out of bounds', () {
      final labels = Labels.load(rawLabels);

      expect(() => labels.at(99), throwsA(isA<Exception>()));
    });

    test('throws when labels file is empty', () {
      expect(() => Labels.load(''), throwsA(isA<Exception>()));
    });

    test('throws when label format is invalid', () {
      expect(
        () => Labels.load('InvalidLabel'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
