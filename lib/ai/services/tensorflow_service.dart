import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../config/ai_config.dart';
import '../exceptions/ai_exceptions.dart';
import '../labels/labels.dart';
import '../model/prediction.dart';
import '../utils/image_processor.dart';

/// Contrat du moteur d'inférence TensorFlow Lite.
abstract class TensorFlowService {
  Future<void> initialize({AiConfig? config});

  Future<Prediction> predict(InputTensor input);

  void dispose();

  bool get isInitialized;
}

/// Implémentation TensorFlow Lite.
class TfliteTensorFlowService implements TensorFlowService {
  Interpreter? _interpreter;
  Labels? _labels;
  AiConfig _config = const AiConfig();

  /// Score minimal requis pour accepter une prédiction.
  ///
  /// Ajuste cette valeur après les tests :
  /// - plus haut = plus strict ;
  /// - plus bas = accepte davantage de résultats.
  static const double _minimumConfidence = 0.75;

  /// Écart minimal requis entre le premier et le deuxième résultat.
  ///
  /// Si les deux scores sont proches, le modèle hésite.
  static const double _minimumConfidenceGap = 0.15;

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
          'Incompatibilité modèle/labels : '
          '$numClasses classes dans le modèle, '
          '${_labels!.length} labels dans labels.txt.',
        );
      }

      debugPrint('===== MODEL INFO =====');
      debugPrint('INPUT: ${_interpreter!.getInputTensor(0).shape}');
      debugPrint('INPUT TYPE: ${_interpreter!.getInputTensor(0).type}');
      debugPrint('OUTPUT: ${_interpreter!.getOutputTensor(0).shape}');
      debugPrint('OUTPUT TYPE: ${_interpreter!.getOutputTensor(0).type}');
      debugPrint('LABELS: ${_labels!.length}');
      debugPrint('======================');
    } on AiException {
      rethrow;
    } catch (e) {
      throw TensorFlowException('Erreur init TensorFlow.', e);
    }
  }

  @override
  Future<Prediction> predict(InputTensor input) async {
    if (!isInitialized) {
      throw const TensorFlowException(
        'TensorFlowService non initialisé.',
      );
    }

    try {
      final numClasses = _labels!.length;

      final output = List.generate(
        1,
        (_) => List<double>.filled(numClasses, 0.0),
      );

      _interpreter!.run(input, output);

      final probabilities = output[0];

      if (probabilities.isEmpty) {
        throw const TensorFlowException(
          'Le modèle n’a retourné aucune probabilité.',
        );
      }

      final indexedScores = List.generate(
        probabilities.length,
        (index) => MapEntry<int, double>(
          index,
          probabilities[index].toDouble(),
        ),
      )..sort((a, b) => b.value.compareTo(a.value));

      final bestIndex = indexedScores.first.key;
      final bestConfidence = indexedScores.first.value;

      final secondConfidence = indexedScores.length > 1
          ? indexedScores[1].value
          : 0.0;

      final confidenceGap = bestConfidence - secondConfidence;

      debugPrint('===== PROBABILITES CLASSEES =====');

      for (final score in indexedScores) {
        final label = _labels!.at(score.key);

        debugPrint(
          '${score.key + 1}. '
          '${label.displayCrop} - ${label.displayDisease} '
          '(${label.diseaseKey}) : '
          '${(score.value * 100).toStringAsFixed(2)} %',
        );
      }

      debugPrint('=================================');
      debugPrint(
        'MEILLEUR SCORE : '
        '${(bestConfidence * 100).toStringAsFixed(2)} %',
      );
      debugPrint(
        'DEUXIEME SCORE : '
        '${(secondConfidence * 100).toStringAsFixed(2)} %',
      );
      debugPrint(
        'ECART : '
        '${(confidenceGap * 100).toStringAsFixed(2)} %',
      );

      final isLowConfidence = bestConfidence < _minimumConfidence;
      final isAmbiguous = confidenceGap < _minimumConfidenceGap;

      if (isLowConfidence || isAmbiguous) {
        debugPrint(
          'PREDICTION REJETEE : '
          '${isLowConfidence ? "score trop faible" : "le modèle hésite"}.',
        );

        return Prediction(
          crop: 'Plante non reconnue',
          disease: 'Diagnostic non fiable',
          confidence: bestConfidence,
          diseaseKey: 'unknown',
          date: DateTime.now(),
        );
      }

      final label = _labels!.at(bestIndex);

      debugPrint(
        'PREDICTION ACCEPTEE => '
        '${label.displayCrop} - ${label.displayDisease} '
        '(${label.diseaseKey}) => '
        '${(bestConfidence * 100).toStringAsFixed(2)} %',
      );

      return Prediction(
        crop: label.displayCrop,
        disease: label.displayDisease,
        confidence: bestConfidence,
        diseaseKey: label.diseaseKey,
        date: DateTime.now(),
      );
    } on AiException {
      rethrow;
    } catch (e) {
      throw TensorFlowException('Erreur inference TensorFlow.', e);
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }

  Future<void> disposeAsync() async {
    dispose();
  }
}