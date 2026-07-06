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

  @override
  bool get isInitialized => _interpreter != null && _labels != null;

  @override
  Future<void> initialize({AiConfig? config}) async {
    _config = config ?? _config;

    await disposeAsync();

    try {
      _interpreter = await Interpreter.fromAsset(_config.modelAssetPath);
      _labels = await Labels.fromAsset(_config.labelsAssetPath);

      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      final outputShape = outputTensor.shape;
      final numClasses = outputShape.last;

      if (numClasses != _labels!.length) {
        throw TensorFlowException(
          'Incompatibilité modèle/labels : '
          '$numClasses classes dans le modèle, '
          '${_labels!.length} labels dans labels.txt.',
        );
      }

      debugPrint('========== MODELE IA ==========');
      debugPrint('INPUT SHAPE : ${inputTensor.shape}');
      debugPrint('INPUT TYPE  : ${inputTensor.type}');
      debugPrint('OUTPUT SHAPE: ${outputTensor.shape}');
      debugPrint('OUTPUT TYPE : ${outputTensor.type}');
      debugPrint('LABELS      : ${_labels!.length}');
      debugPrint('SEUIL CONFIANCE : ${_config.minimumConfidence}');
      debugPrint('ECART TOP 1/TOP 2 : ${_config.minimumConfidenceGap}');
      debugPrint('================================');
    } on AiException {
      rethrow;
    } catch (e) {
      throw TensorFlowException(
        'Erreur lors de l’initialisation TensorFlow Lite.',
        e,
      );
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

      final indexedProbabilities = List.generate(
        probabilities.length,
        (index) => _ClassScore(
          index: index,
          score: probabilities[index].toDouble(),
        ),
      )..sort((a, b) => b.score.compareTo(a.score));

      final top1 = indexedProbabilities[0];

      final top2 = indexedProbabilities.length > 1
          ? indexedProbabilities[1]
          : const _ClassScore(index: -1, score: 0.0);

      final confidenceGap = top1.score - top2.score;

      final bestLabel = _labels!.at(top1.index);

      debugPrint('========== RESULTAT IA ==========');
      debugPrint(
        'TOP 1 : ${bestLabel.displayCrop} - '
        '${bestLabel.displayDisease} '
        '(${bestLabel.diseaseKey}) '
        '= ${(top1.score * 100).toStringAsFixed(2)}%',
      );

      if (top2.index >= 0) {
        final secondLabel = _labels!.at(top2.index);

        debugPrint(
          'TOP 2 : ${secondLabel.displayCrop} - '
          '${secondLabel.displayDisease} '
          '(${secondLabel.diseaseKey}) '
          '= ${(top2.score * 100).toStringAsFixed(2)}%',
        );
      }

      debugPrint(
        'ECART TOP 1 / TOP 2 : '
        '${(confidenceGap * 100).toStringAsFixed(2)}%',
      );
      debugPrint('=================================');

      final hasEnoughConfidence =
          top1.score >= _config.minimumConfidence;

      final hasEnoughGap =
          confidenceGap >= _config.minimumConfidenceGap;

      final isAccepted = hasEnoughConfidence && hasEnoughGap;

      if (!isAccepted) {
        debugPrint('PREDICTION REJETEE : image non reconnue ou incertaine.');

        return Prediction(
          crop: 'Plante non reconnue',
          disease: 'Diagnostic incertain',
          confidence: top1.score,
          diseaseKey: 'unknown',
          date: DateTime.now(),
          isAccepted: false,
        );
      }

      debugPrint('PREDICTION ACCEPTEE.');

      return Prediction(
        crop: bestLabel.displayCrop,
        disease: bestLabel.displayDisease,
        confidence: top1.score,
        diseaseKey: bestLabel.diseaseKey,
        date: DateTime.now(),
        isAccepted: true,
      );
    } on AiException {
      rethrow;
    } catch (e) {
      throw TensorFlowException(
        'Erreur pendant l’inférence TensorFlow Lite.',
        e,
      );
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

/// Classe interne utilisée pour trier les probabilités.
class _ClassScore {
  const _ClassScore({
    required this.index,
    required this.score,
  });

  final int index;
  final double score;
}