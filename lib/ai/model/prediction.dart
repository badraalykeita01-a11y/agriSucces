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
    required this.isAccepted,
  });

  /// Culture identifiée (ex. « Tomate »).
  final String crop;

  /// Maladie identifiée (ex. « Alternariose »).
  final String disease;

  /// Score de confiance du modèle entre 0.0 et 1.0.
  final double confidence;

  /// Clé unique pour croiser avec [DiseaseRepository].
  final String diseaseKey;

  /// Horodatage de la prédiction.
  final DateTime date;

  /// Indique si le diagnostic a passé les seuils de confiance.
  final bool isAccepted;

  /// Diagnostic rejeté ou non reconnu.
  bool get isUnknown => diseaseKey == 'unknown';

  /// Plante saine reconnue avec confiance suffisante.
  bool get isHealthy => !isUnknown && diseaseKey.endsWith('_healthy');

  /// Diagnostic accepté et exploitable par l'interface.
  bool get isReliable => isAccepted && !isUnknown;

  Prediction copyWith({
    String? crop,
    String? disease,
    double? confidence,
    String? diseaseKey,
    DateTime? date,
    bool? isAccepted,
  }) {
    return Prediction(
      crop: crop ?? this.crop,
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      diseaseKey: diseaseKey ?? this.diseaseKey,
      date: date ?? this.date,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'disease': disease,
        'confidence': confidence,
        'diseaseKey': diseaseKey,
        'date': date.toIso8601String(),
        'isAccepted': isAccepted,
      };

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      crop: json['crop'] as String,
      disease: json['disease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      diseaseKey: json['diseaseKey'] as String,
      date: DateTime.parse(json['date'] as String),
      isAccepted: json['isAccepted'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'Prediction(crop: $crop, disease: $disease, confidence: ${confidence.toStringAsFixed(2)}, diseaseKey: $diseaseKey, isAccepted: $isAccepted)';
}
