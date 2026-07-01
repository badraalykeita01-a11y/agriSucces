/// Résultat brut de l'inférence TensorFlow Lite.
///
/// Contient uniquement la classification (culture, maladie, confiance).
/// Les traitements et descriptions complémentaires proviennent de
/// [DiseaseRepository] via [diseaseKey].
class Prediction {
  const Prediction({
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.diseaseKey,
    required this.date,
  });

  /// Culture identifiée (ex. « Tomate »).
  final String crop;

  /// Maladie identifiée (ex. « Alternariose »).
  final String disease;

  /// Score de confiance du modèle entre 0.0 et 1.0.
  final double confidence;

  /// Clé unique pour croiser avec [DiseaseRepository] (ex. `tomato_early_blight`).
  final String diseaseKey;

  /// Horodatage de la prédiction.
  final DateTime date;

  Prediction copyWith({
    String? crop,
    String? disease,
    double? confidence,
    String? diseaseKey,
    DateTime? date,
  }) {
    return Prediction(
      crop: crop ?? this.crop,
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      diseaseKey: diseaseKey ?? this.diseaseKey,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'disease': disease,
        'confidence': confidence,
        'diseaseKey': diseaseKey,
        'date': date.toIso8601String(),
      };

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      crop: json['crop'] as String,
      disease: json['disease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      diseaseKey: json['diseaseKey'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  @override
  String toString() =>
      'Prediction(crop: $crop, disease: $disease, confidence: ${confidence.toStringAsFixed(2)}, diseaseKey: $diseaseKey)';
}
