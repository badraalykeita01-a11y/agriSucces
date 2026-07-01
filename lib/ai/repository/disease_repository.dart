import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/ai_config.dart';
import '../exceptions/ai_exceptions.dart';
import '../model/disease_info.dart';

/// Repository offline pour les informations complémentaires des maladies.
///
/// Lit `assets/data/diseases.json` et expose nom, description, gravité,
/// causes, traitement et prévention. Le modèle IA ne contient jamais ces données.
class DiseaseRepository {
  DiseaseRepository({AiConfig config = const AiConfig()}) : _config = config;

  final AiConfig _config;

  Map<String, DiseaseInfo>? _cache;

  /// Charge et met en cache le fichier JSON des maladies.
  Future<void> load() async {
    if (_cache != null) return;

    try {
      final rawJson = await rootBundle.loadString(_config.diseasesAssetPath);
      final decoded = json.decode(rawJson);

      if (decoded is! Map<String, dynamic>) {
        throw const DiseaseDataException(
          'Format JSON invalide: racine attendue de type Map.',
        );
      }

      _cache = decoded.map((key, value) {
        if (value is! Map<String, dynamic>) {
          throw DiseaseDataException(
            'Entrée invalide pour la clé "$key": objet attendu.',
          );
        }
        return MapEntry(key, DiseaseInfo.fromJson(key, value));
      });
    } on FlutterError catch (e) {
      throw DiseaseDataException(
        'Fichier diseases.json introuvable: ${_config.diseasesAssetPath}',
        e,
      );
    } on DiseaseDataException {
      rethrow;
    } on FormatException catch (e) {
      throw DiseaseDataException('Erreur de parsing JSON des maladies.', e);
    } catch (e) {
      throw DiseaseDataException(
        'Erreur inattendue lors du chargement des maladies.',
        e,
      );
    }
  }

  /// Retourne les informations d'une maladie par sa clé ([Prediction.diseaseKey]).
  Future<DiseaseInfo> getByKey(String diseaseKey) async {
    await load();
    final info = _cache![diseaseKey];
    if (info == null) {
      throw DiseaseDataException(
        'Aucune maladie trouvée pour la clé "$diseaseKey".',
      );
    }
    return info;
  }

  /// Retourne toutes les maladies disponibles.
  Future<List<DiseaseInfo>> getAll() async {
    await load();
    return _cache!.values.toList();
  }

  /// Retourne les maladies d'une culture donnée (ex. « Tomate »).
  Future<List<DiseaseInfo>> getByCrop(String crop) async {
    await load();
    return _cache!.values.where((info) => info.crop == crop).toList();
  }

  /// Vide le cache (utile pour les tests ou rechargement).
  void clearCache() => _cache = null;
}
