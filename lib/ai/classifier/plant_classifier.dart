import 'dart:io';
import 'dart:typed_data';

import '../config/ai_config.dart';
import '../exceptions/ai_exceptions.dart';
import '../model/prediction.dart';
import '../services/tensorflow_service.dart';
import '../utils/image_processor.dart';

/// Orchestrateur de classification des maladies des plantes.
///
/// Coordonne le prétraitement d'image ([ImageProcessor]) et l'inférence
/// ([TensorFlowService]) pour produire une [Prediction].
class PlantClassifier {
  PlantClassifier({
    required TensorFlowService tensorFlowService,
    required ImageProcessor imageProcessor,
    AiConfig config = const AiConfig(),
  })  : _tensorFlowService = tensorFlowService,
        _imageProcessor = imageProcessor,
        _config = config;

  final TensorFlowService _tensorFlowService;
  final ImageProcessor _imageProcessor;
  final AiConfig _config;

  /// Initialise le moteur IA (modèle + labels).
  Future<void> initialize() => _tensorFlowService.initialize(config: _config);

  /// Classifie une image à partir de bytes bruts.
  Future<Prediction> classifyFromBytes(Uint8List imageBytes) async {
    _ensureInitialized();
    final tensor = _imageProcessor.preprocessFromBytes(imageBytes);
    return _tensorFlowService.predict(tensor);
  }

  /// Classifie une image à partir d'un fichier local.
  Future<Prediction> classifyFromFile(File imageFile) async {
    _ensureInitialized();
    final tensor = await _imageProcessor.preprocessFromFile(imageFile);
    return _tensorFlowService.predict(tensor);
  }

  /// Libère les ressources du moteur IA.
  void dispose() => _tensorFlowService.dispose();

  void _ensureInitialized() {
    if (!_tensorFlowService.isInitialized) {
      throw const TensorFlowException(
        'PlantClassifier non initialisé. Appelez initialize() d\'abord.',
      );
    }
  }
}
