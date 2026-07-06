import 'package:flutter/foundation.dart'; // Defines FlutterError
import 'package:flutter/services.dart';   // Defines rootBundleimport 'package:flutter/services.dart';
import '../exceptions/ai_exceptions.dart';

/// Correspondance exacte entre chaque label du modèle TensorFlow Lite
/// et sa clé dans assets/data/diseases.json.
///
/// Important : les textes à gauche doivent être exactement les mêmes
/// que ceux présents dans labels.txt.
const Map<String, String> diseaseKeyByLabel = {
  'Corn___Cercospora_leaf_spot Gray_leaf_spot': 'corn_cercospora_leaf_spot_gray_leaf_spot',
  'Corn___Common_rust_': 'corn_common_rust',
  'Corn___healthy': 'corn_healthy',
  'Corn___Northern_Leaf_Blight': 'corn_northern_leaf_blight',
  'Pepper_bell___Bacterial_spot': 'pepper_bell_bacterial_spot',
  'Pepper_bell___healthy': 'pepper_bell_healthy',
  'Potato___Early_blight': 'potato_early_blight',
  'Potato___healthy': 'potato_healthy',
  'Potato___Late_blight': 'potato_late_blight',
  'Tomato___Bacterial_spot': 'tomato_bacterial_spot',
  'Tomato___Early_blight': 'tomato_early_blight',
  'Tomato___healthy': 'tomato_healthy',
  'Tomato___Late_blight': 'tomato_late_blight',
  'Tomato___Leaf_Mold': 'tomato_leaf_mold',
  'Tomato___Septoria_leaf_spot': 'tomato_septoria_leaf_spot',
  'Tomato___Spider_mites Two-spotted_spider_mite': 'tomato_spider_mites_two-spotted_spider_mite',
  'Tomato___Target_Spot': 'tomato_target_spot',
  'Tomato___Tomato_mosaic_virus': 'tomato_tomato_mosaic_virus',
  'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 'tomato_tomato_yellow_leaf_curl_virus',
};

/// Une classe présente dans labels.txt.
class LabelEntry {
  const LabelEntry({
    required this.index,
    required this.originalLabel,
    required this.crop,
    required this.disease,
    required this.diseaseKey,
    required this.displayCrop,
    required this.displayDisease,
    required this.isHealthy,
  });

  final int index;
  final String originalLabel;
  final String crop;
  final String disease;

  /// Clé exacte utilisée pour retrouver les informations dans diseases.json.
  final String diseaseKey;

  final String displayCrop;
  final String displayDisease;
  final bool isHealthy;
}

/// Charge et interprète labels.txt.
class Labels {
  Labels._(this._entries);

  final List<LabelEntry> _entries;

  int get length => _entries.length;

  List<LabelEntry> get all => List.unmodifiable(_entries);

  LabelEntry at(int index) {
    if (index < 0 || index >= _entries.length) {
      throw TensorFlowException(
        'Indice de label invalide : $index. Numéro de labels : ${_entries.length}.',
      );
    }
    return _entries[index];
  }

  factory Labels.load(String rawContent) {
    final lines = rawContent
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw const LabelsNotFoundException('labels.txt est vide.');
    }

    final entries = <LabelEntry>[];
    final usedKeys = <String>{};

    for (var i = 0; i < lines.length; i++) {
      // Changed from _parseLabel to parseLabel since your method is public
      final entry = parseLabel(i, lines[i]);

      if (!usedKeys.add(entry.diseaseKey)) {
        throw LabelsNotFoundException(
          'Clé diseaseKey dupliquée : ${entry.diseaseKey}',
        );
      }

      entries.add(entry);
    }

    return Labels._(entries);
  }

  static Future<Labels> fromAsset(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      return Labels.load(content);
    } on FlutterError catch (e) {
      throw LabelsNotFoundException('Impossible de charger labels.txt : $assetPath', e);
    } on LabelsNotFoundException {
      rethrow;
    } catch (e) {
      throw LabelsNotFoundException('Erreur lors de la lecture de labels.txt.');
    }
  }

  static LabelEntry parseLabel(int index, String originalLabel) {
    // Fixed the pattern to separate using '___' instead of '*__'
    final parts = originalLabel.split('___');

    if (parts.length != 2) {
      throw LabelsNotFoundException(
        'Label invalide à la ligne ${index + 1} : "$originalLabel". '
        'Format attendu : Culture___Maladie.',
      );
    }

    final crop = parts[0].trim();
    final disease = parts[1].trim();

    final normalizedDisease = disease
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'_+$'), '');

    final isHealthy = normalizedDisease == 'healthy';

    /// Ici on récupère la clé officielle définie dans la map.
    final diseaseKey = diseaseKeyByLabel[originalLabel];

    if (diseaseKey == null) {
      throw LabelsNotFoundException(
        'Aucune clé JSON trouvée pour le label : "$originalLabel". '
        'Ajoute ce label dans diseaseKeyByLabel.',
      );
    }

    return LabelEntry(
      index: index,
      originalLabel: originalLabel,
      crop: crop,
      disease: disease,
      diseaseKey: diseaseKey,
      displayCrop: cropToFrench(crop),
      displayDisease: _diseaseToFrench(normalizedDisease, isHealthy),
      isHealthy: isHealthy,
    );
  }

  static String cropToFrench(String crop) {
    final normalized = crop.toLowerCase().replaceAll('_', '');

    switch (normalized) {
      case 'corn':
        return 'Maïs';
      case 'pepperbell':
        return 'Poivron / Piment';
      case 'potato':
        return 'Pomme de terre';
      case 'tomato':
        return 'Tomate';
      default:
        return crop.replaceAll('_', ' ');
    }
  }

  static String _diseaseToFrench(String normalizedDisease, bool isHealthy) {
    if (isHealthy) return 'Plante saine';

    switch (normalizedDisease) {
      case 'cercospora_leaf_spot_gray_leaf_spot':
        return 'Cercosporiose / tache grise des feuilles';
      case 'common_rust':
        return 'Rouille commune';
      case 'northern_leaf_blight':
        return 'Helminthosporiose';
      case 'bacterial_spot':
        return 'Tache bactérienne';
      case 'early_blight':
        return 'Alternariose';
      case 'late_blight':
        return 'Mildiou';
      case 'leaf_mold':
        return 'Moisissure des feuilles';
      case 'septoria_leaf_spot':
        return 'Septoriose';
      case 'spider_mites_two-spotted_spider_mite':
        return 'Acariens (tétranyques)';
      case 'target_spot':
        return 'Tache cible';
      case 'tomato_mosaic_virus':
        return 'Virus de la mosaïque de la tomate';
      case 'tomato_yellow_leaf_curl_virus':
        return 'Virus de l’enroulement jaune de la tomate';
      default:
        return normalizedDisease.replaceAll('_', ' ');
    }
  }
}