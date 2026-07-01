import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agrisucces/ai/config/ai_config.dart';
import 'package:agrisucces/ai/classifier/plant_classifier.dart';
import 'package:agrisucces/ai/model/prediction.dart';
import 'package:agrisucces/ai/repository/disease_repository.dart';
import 'package:agrisucces/ai/services/tensorflow_service.dart';
import 'package:agrisucces/ai/utils/image_processor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Uint8List createTestPng() {
    final image = img.Image(width: 10, height: 10);
    img.fill(image, color: img.ColorRgb8(100, 150, 50));
    return Uint8List.fromList(img.encodePng(image));
  }

  group('DiseaseRepository', () {
    setUp(() async {});

    test('loads diseases from assets and retrieves by key', () async {
      final repository = DiseaseRepository();
      await repository.load();

      final info = await repository.getByKey('tomato_early_blight');

      expect(info.crop, 'Tomate');
      expect(info.name, contains('Alternariose'));
      expect(info.causes, isNotEmpty);
      expect(info.treatment, isNotEmpty);
      expect(info.prevention, isNotEmpty);
    });

    test('getByCrop filters by culture', () async {
      final repository = DiseaseRepository();
      final tomatoDiseases = await repository.getByCrop('Tomate');

      expect(tomatoDiseases, isNotEmpty);
      expect(tomatoDiseases.every((d) => d.crop == 'Tomate'), isTrue);
    });

    test('throws for unknown disease key', () async {
      final repository = DiseaseRepository();
      await repository.load();

      expect(
        () => repository.getByKey('unknown_disease'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PlantClassifier', () {
    test('classifies image using mocked TensorFlowService', () async {
      final mockService = _MockTensorFlowService();
      final classifier = PlantClassifier(
        tensorFlowService: mockService,
        imageProcessor: ImageProcessor(),
      );

      await classifier.initialize();

      final prediction = await classifier.classifyFromBytes(createTestPng());

      expect(prediction.crop, 'Tomate');
      expect(prediction.diseaseKey, 'tomato_early_blight');
      expect(prediction.confidence, greaterThan(0));
    });
  });
}

class _MockTensorFlowService implements TensorFlowService {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize({AiConfig? config}) async {
    _initialized = true;
  }

  @override
  Future<Prediction> predict(InputTensor input) async {
    return Prediction(
      crop: 'Tomate',
      disease: 'Alternariose',
      confidence: 0.95,
      diseaseKey: 'tomato_early_blight',
      date: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _initialized = false;
  }
}
