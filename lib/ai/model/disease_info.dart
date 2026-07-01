/// Informations complémentaires sur une maladie, chargées depuis `diseases.json`.
///
/// Le modèle IA ne contient jamais ces données — elles sont récupérées
/// offline via [DiseaseRepository].
class DiseaseInfo {
  const DiseaseInfo({
    required this.diseaseKey,
    required this.crop,
    required this.name,
    required this.description,
    required this.severity,
    required this.causes,
    required this.treatment,
    required this.prevention,
  });

  /// Clé unique correspondant à [Prediction.diseaseKey].
  final String diseaseKey;

  /// Culture concernée.
  final String crop;

  /// Nom courant de la maladie.
  final String name;

  /// Description détaillée des symptômes.
  final String description;

  /// Niveau de gravité (ex. « Modérée », « Élevée »).
  final String severity;

  /// Causes connues de la maladie.
  final List<String> causes;

  /// Traitements recommandés.
  final List<String> treatment;

  /// Mesures préventives.
  final List<String> prevention;

  factory DiseaseInfo.fromJson(String diseaseKey, Map<String, dynamic> json) {
    return DiseaseInfo(
      diseaseKey: diseaseKey,
      crop: json['crop'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      causes: List<String>.from(json['causes'] as List<dynamic>? ?? []),
      treatment: List<String>.from(json['treatment'] as List<dynamic>? ?? []),
      prevention: List<String>.from(json['prevention'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'name': name,
        'description': description,
        'severity': severity,
        'causes': causes,
        'treatment': treatment,
        'prevention': prevention,
      };
}
