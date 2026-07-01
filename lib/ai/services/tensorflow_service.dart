import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../config/ai_config.dart';
import '../exceptions/ai_exceptions.dart';
import '../labels/labels.dart';
import '../model/prediction.dart';
import '../utils/image_processor.dart';

/// Contrat du moteur d'inférence TensorFlow Lite.
///
/// Implémentez cette interface pour remplacer facilement le backend IA
/// (mock en tests, autre modèle, service cloud futur, etc.).
abstract class TensorFlowService {
  /// Charge le modèle et les labels depuis les assets.
  Future<void> initialize({AiConfig? config});

  /// Exécute l'inférence et retourne une [Prediction] sans données de traitement.
  Future<Prediction> predict(InputTensor input);

  /// Libère les ressources natives du modèle.
  void dispose();

  /// Indique si le service est prêt pour l'inférence.
  bool get isInitialized;
}

/// Implémentation TensorFlow Lite utilisant [Interpreter].
class TfliteTensorFlowService implements TensorFlowService {
  Interpreter? _interpreter;
  Labels? _labels;
  AiConfig _config = const AiConfig();

  @override
  bool get isInitialized => _interpreter != null && _labels != null;

  @override
  Future<void> initialize({AiConfig? config}) async {
    _config = config ?? _config;
    await disposeAsync();

    try {
      _interpreter = await Interpreter.fromAsset(_config.modelAssetPath);
      _labels = await Labels.fromAsset(_config.labelsAssetPath);

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final numClasses = outputShape.last;
      if (numClasses != _labels!.length) {
        throw TensorFlowException(
          'Incompatibilité modèle/labels: le modèle produit $numClasses classes '
          'mais labels.txt en contient ${_labels!.length}.',
        );
      }
    } on AiException {
      rethrow;
    } on FlutterError catch (e) {
      throw ModelNotFoundException(
        'Modèle introuvable: ${_config.modelAssetPath}',
        e,
      );
    } catch (e) {
      throw TensorFlowException(
        'Erreur lors de l\'initialisation TensorFlow Lite.',
        e,
      );
    }
  }

  @override
  Future<Prediction> predict(InputTensor input) async {
    if (!isInitialized) {
      throw const TensorFlowException(
        'TensorFlowService non initialisé. Appelez initialize() d\'abord.',
      );
    }

    try {
      final numClasses = _labels!.length;
      final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

      _interpreter!.run(input, output);

      final probabilities = output[0];
      var maxIndex = 0;
      var maxConfidence = probabilities[0];

      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }

      final label = _labels!.at(maxIndex);

      return Prediction(
        crop: label.displayCrop,
        disease: label.displayDisease,
        confidence: maxConfidence.toDouble(),
        diseaseKey: label.diseaseKey,
        date: DateTime.now(),
      );
    } catch (e) {
      if (e is AiException) rethrow;
      throw TensorFlowException('Erreur lors de l\'inférence TensorFlow Lite.', e);
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }

  /// Variante async de [dispose] pour réinitialisation propre.
  Future<void> disposeAsync() async {
    dispose();
  }
}
