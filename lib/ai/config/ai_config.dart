class AiConfig {
  const AiConfig({
    this.modelAssetPath = 'assets/model/plant_disease.tflite',
    this.labelsAssetPath = 'assets/model/labels.txt',
    this.diseasesAssetPath = 'assets/data/diseases.json',
    this.inputWidth = 224,
    this.inputHeight = 224,
    this.inputChannels = 3,
    this.normalizeMean = 0.0,
    this.normalizeStd = 255.0,
    this.minimumConfidence = 0.60,
  });

  final String modelAssetPath;
  final String labelsAssetPath;
  final String diseasesAssetPath;

  final int inputWidth;
  final int inputHeight;
  final int inputChannels;

  /// Transforme les pixels RGB de 0–255 vers 0–1.
  final double normalizeMean;
  final double normalizeStd;

  /// En dessous de ce score, l'application ne doit pas annoncer un diagnostic.
  final double minimumConfidence;
}