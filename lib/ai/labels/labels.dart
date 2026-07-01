import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../exceptions/ai_exceptions.dart';

/// Entrée de label associée à un indice de sortie du modèle TFLite.
class LabelEntry {
  const LabelEntry({
    required this.index,
    required this.rawLabel,
    required this.crop,
    required this.disease,
    required this.diseaseKey,
    required this.displayCrop,
    required this.displayDisease,
  });

  /// Indice de la classe dans le tenseur de sortie.
  final int index;

  /// Label brut tel que défini dans `labels.txt` (ex. `Tomato___Early_blight`).
  final String rawLabel;

  /// Identifiant culture en anglais (ex. `Tomato`).
  final String crop;

  /// Identifiant maladie en anglais (ex. `Early_blight`).
  final String disease;

  /// Clé snake_case pour croiser avec `diseases.json` (ex. `tomato_early_blight`).
  final String diseaseKey;

  /// Nom affiché de la culture en français.
  final String displayCrop;

  /// Nom affiché de la maladie (lisible).
  final String displayDisease;
}

/// Associe les indices TensorFlow Lite aux classes de classification.
class Labels {
  Labels._(this._entries);

  final List<LabelEntry> _entries;

  /// Nombre total de classes.
  int get length => _entries.length;

  /// Charge les labels depuis une chaîne brute (contenu de `labels.txt`).
  factory Labels.load(String rawContent) {
    final lines = rawContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw const LabelsNotFoundException(
        'Le fichier labels.txt est vide ou ne contient aucune classe.',
      );
    }

    final entries = <LabelEntry>[];
    for (var i = 0; i < lines.length; i++) {
      entries.add(_parseLabel(i, lines[i]));
    }
    return Labels._(entries);
  }

  /// Charge les labels depuis un asset Flutter.
  static Future<Labels> fromAsset(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      return Labels.load(content);
    } on FlutterError catch (e) {
      throw LabelsNotFoundException(
        'Impossible de charger labels.txt depuis $assetPath.',
        e,
      );
    } on LabelsNotFoundException {
      rethrow;
    } catch (e) {
      throw LabelsNotFoundException(
        'Erreur lors du chargement des labels.',
        e,
      );
    }
  }

  /// Retourne l'entrée correspondant à un indice de sortie du modèle.
  LabelEntry at(int index) {
    if (index < 0 || index >= _entries.length) {
      throw TensorFlowException(
        'Indice de label hors limites: $index (max: ${_entries.length - 1}).',
      );
    }
    return _entries[index];
  }

  /// Liste immuable de toutes les entrées.
  List<LabelEntry> get all => List.unmodifiable(_entries);

  static LabelEntry _parseLabel(int index, String rawLabel) {
    final parts = rawLabel.split('___');
    if (parts.length != 2) {
      throw LabelsNotFoundException(
        'Format de label invalide à l\'indice $index: "$rawLabel". '
        'Format attendu: Culture___Maladie',
      );
    }

    final crop = parts[0].trim();
    final disease = parts[1].trim();
    final diseaseKey = '${crop.toLowerCase()}_${disease.toLowerCase()}';

    return LabelEntry(
      index: index,
      rawLabel: rawLabel,
      crop: crop,
      disease: disease,
      diseaseKey: diseaseKey,
      displayCrop: _mapCropToFrench(crop),
      displayDisease: _mapDiseaseToFrench(disease),
    );
  }

  static String _mapCropToFrench(String crop) {
    return switch (crop.toLowerCase()) {
      'tomato' => 'Tomate',
      'potato' => 'Pomme de terre',
      'corn' => 'Maïs',
      'pepper' => 'Poivron / Piment',
      _ => crop,
    };
  }

  static String _mapDiseaseToFrench(String disease) {
    return switch (disease.toLowerCase()) {
      'early_blight' => 'Alternariose',
      'late_blight' => 'Mildiou',
      'leaf_mold' => 'Moisissure des feuilles',
      'common_rust' => 'Rouille commune',
      'gray_leaf_spot' => 'Tache grise des feuilles',
      'northern_leaf_blight' => 'Helminthosporiose',
      'bacterial_spot' => 'Tache bacterienne',
      'healthy' => 'Plante saine',
      _ => disease.replaceAll('_', ' '),
    };
  }
}
