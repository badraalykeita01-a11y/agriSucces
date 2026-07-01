/// Configuration centralisée du pipeline IA.
///
/// Permet de remplacer facilement le modèle, les labels ou les dimensions
/// d'entrée via injection Riverpod ([aiConfigProvider]).
class AiConfig {
  const AiConfig({
    this.modelAssetPath = 'assets/model/plant_disease.tflite',
    this.labelsAssetPath = 'assets/model/labels.txt',
    this.diseasesAssetPath = 'assets/data/diseases.json',
    this.inputWidth = 224,
    this.inputHeight = 224,
    this.inputChannels = 3,
    this.normalizeMean = 127.5,
    this.normalizeStd = 127.5,
  });

  /// Chemin asset du modèle TensorFlow Lite.
  final String modelAssetPath;

  /// Chemin asset du fichier de labels (une classe par ligne).
  final String labelsAssetPath;

  /// Chemin asset du fichier JSON des maladies.
  final String diseasesAssetPath;

  /// Largeur attendue par le modèle.
  final int inputWidth;

  /// Hauteur attendue par le modèle.
  final int inputHeight;

  /// Nombre de canaux couleur (RGB = 3).
  final int inputChannels;

  /// Moyenne utilisée pour la normalisation des pixels.
  final double normalizeMean;

  /// Écart-type utilisé pour la normalisation des pixels.
  final double normalizeStd;
}
