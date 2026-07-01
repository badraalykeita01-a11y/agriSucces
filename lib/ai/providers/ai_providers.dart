import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../classifier/plant_classifier.dart';
import '../config/ai_config.dart';
import '../repository/disease_repository.dart';
import '../services/tensorflow_service.dart';
import '../utils/image_processor.dart';

/// Configuration IA injectable (remplaçable en tests via [ProviderScope.overrides]).
final aiConfigProvider = Provider<AiConfig>((ref) => const AiConfig());

/// Service TensorFlow Lite (remplaçable par un mock en tests).
final tensorFlowServiceProvider = Provider<TensorFlowService>((ref) {
  final service = TfliteTensorFlowService();
  ref.onDispose(service.dispose);
  return service;
});

/// Processeur d'images configuré selon [aiConfigProvider].
final imageProcessorProvider = Provider<ImageProcessor>((ref) {
  final config = ref.watch(aiConfigProvider);
  return ImageProcessor(config: config);
});

/// Repository des maladies (données JSON offline).
final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
  final config = ref.watch(aiConfigProvider);
  return DiseaseRepository(config: config);
});

/// Classificateur principal orchestrant le pipeline IA complet.
final plantClassifierProvider = Provider<PlantClassifier>((ref) {
  final config = ref.watch(aiConfigProvider);
  final classifier = PlantClassifier(
    tensorFlowService: ref.watch(tensorFlowServiceProvider),
    imageProcessor: ref.watch(imageProcessorProvider),
    config: config,
  );
  ref.onDispose(classifier.dispose);
  return classifier;
});

/// Initialise le moteur IA et charge les données des maladies au démarrage.
final aiInitializationProvider = FutureProvider<void>((ref) async {
  await ref.read(tensorFlowServiceProvider).initialize(
        config: ref.read(aiConfigProvider),
      );
  await ref.read(diseaseRepositoryProvider).load();
});
