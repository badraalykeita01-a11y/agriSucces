/// Type d'entrée attendu par le modèle TensorFlow Lite.
enum TensorInputType {
  /// Valeurs normalisées en virgule flottante (ex. 0.0 – 1.0).
  float32,

  /// Valeurs entières brutes (0 – 255).
  uint8,
}

/// Configuration centralisée du pipeline IA.
///
/// Permet de remplacer facilement le modèle, les labels ou les dimensions
/// d'entrée via injection Riverpod.
class AiConfig {
  const AiConfig({
    this.modelAssetPath = 'assets/model/plant_disease.tflite',
    this.labelsAssetPath = 'assets/model/labels.txt',
    this.diseasesAssetPath = 'assets/data/diseases.json',
    this.inputWidth = 224,
    this.inputHeight = 224,
    this.inputChannels = 3,
    this.inputType = TensorInputType.float32,
    this.normalizeMean = 0.0,
    this.normalizeStd = 255.0,
    this.minimumConfidence = 0.80,
    this.minimumConfidenceGap = 0.20,
  });

  /// Score minimal pour accepter une prédiction (Top 1).
  static const double defaultMinimumConfidence = 0.80;

  /// Écart minimal requis entre Top 1 et Top 2.
  static const double defaultMinimumConfidenceGap = 0.20;

  /// Chemin asset du modèle TensorFlow Lite.
  final String modelAssetPath;

  /// Chemin asset du fichier de labels.
  final String labelsAssetPath;

  /// Chemin asset du fichier JSON des maladies.
  final String diseasesAssetPath;

  /// Largeur attendue par le modèle.
  final int inputWidth;

  /// Hauteur attendue par le modèle.
  final int inputHeight;

  /// Nombre de canaux couleur (RGB = 3).
  final int inputChannels;

  /// Type de tenseur d'entrée.
  final TensorInputType inputType;

  /// Moyenne utilisée pour la normalisation des pixels (float32).
  final double normalizeMean;

  /// Diviseur utilisé pour la normalisation des pixels (float32).
  final double normalizeStd;

  /// Seuil minimal de confiance pour accepter un diagnostic.
  final double minimumConfidence;

  /// Écart minimal entre la 1re et la 2e prédiction.
  final double minimumConfidenceGap;

  /// Copie avec des dimensions lues dynamiquement depuis le modèle.
  AiConfig copyWith({
    int? inputWidth,
    int? inputHeight,
    int? inputChannels,
    TensorInputType? inputType,
  }) {
    return AiConfig(
      modelAssetPath: modelAssetPath,
      labelsAssetPath: labelsAssetPath,
      diseasesAssetPath: diseasesAssetPath,
      inputWidth: inputWidth ?? this.inputWidth,
      inputHeight: inputHeight ?? this.inputHeight,
      inputChannels: inputChannels ?? this.inputChannels,
      inputType: inputType ?? this.inputType,
      normalizeMean: normalizeMean,
      normalizeStd: normalizeStd,
      minimumConfidence: minimumConfidence,
      minimumConfidenceGap: minimumConfidenceGap,
    );
  }
}
