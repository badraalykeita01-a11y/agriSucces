/// Informations complémentaires sur une maladie, chargées depuis
/// `assets/data/diseases.json`.
///
/// Le modèle TensorFlow Lite fournit uniquement une classe et une confiance.
/// Les conseils agricoles sont chargés offline depuis le JSON.
class DiseaseInfo {
  const DiseaseInfo({
    required this.diseaseKey,
    required this.crop,
    required this.name,
    required this.severity,
    required this.description,
    required this.causes,
    required this.symptoms,
    required this.immediateActions,
    required this.organicOptions,
    required this.chemicalOptions,
    required this.prevention,
    required this.whenToSeekHelp,
    required this.needsReview,
  });

  final String diseaseKey;
  final String crop;
  final String name;

  /// Valeurs attendues : low, medium ou high.
  final String severity;

  final String description;
  final List<String> causes;
  final List<String> symptoms;
  final List<String> immediateActions;
  final List<String> organicOptions;
  final List<String> chemicalOptions;
  final List<String> prevention;
  final List<String> whenToSeekHelp;

  /// Indique que les conseils doivent être vérifiés par un spécialiste.
  final bool needsReview;

  factory DiseaseInfo.fromJson(String diseaseKey, Map<String, dynamic> json) {
    List<String> readList(String key) {
      final value = json[key];

      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }

      return const [];
    }

    return DiseaseInfo(
      diseaseKey: diseaseKey,
      crop: (json['crop'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      severity: (json['severity'] ?? 'medium').toString().toLowerCase(),
      description: (json['description'] ?? '').toString(),
      causes: readList('causes'),
      symptoms: readList('symptoms'),
      immediateActions: readList('immediateActions'),
      organicOptions: readList('organicOptions'),
      chemicalOptions: readList('chemicalOptions'),
      prevention: readList('prevention'),
      whenToSeekHelp: readList('whenToSeekHelp'),
      needsReview: json['needsReview'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'name': name,
      'severity': severity,
      'description': description,
      'causes': causes,
      'symptoms': symptoms,
      'immediateActions': immediateActions,
      'organicOptions': organicOptions,
      'chemicalOptions': chemicalOptions,
      'prevention': prevention,
      'whenToSeekHelp': whenToSeekHelp,
      'needsReview': needsReview,
    };
  }
}