import 'dart:convert';

import 'package:flutter/services.dart';

import '../ai/model/disease_info.dart';

class DiseaseRepository {
  static const String _assetPath = 'assets/data/diseases.json';

  Map<String, DiseaseInfo>? _cache;

  /// Charge toutes les maladies depuis diseases.json.
  Future<Map<String, DiseaseInfo>> getAll() async {
    if (_cache != null) {
      return _cache!;
    }

    final rawJson = await rootBundle.loadString(_assetPath);

    final Map<String, dynamic> decoded =
        Map<String, dynamic>.from(jsonDecode(rawJson) as Map);

    final diseases = <String, DiseaseInfo>{};

    decoded.forEach((diseaseKey, value) {
      if (value is Map) {
        diseases[diseaseKey] = DiseaseInfo.fromJson(
          diseaseKey,
          Map<String, dynamic>.from(value),
        );
      }
    });

    _cache = diseases;

    return diseases;
  }

  /// Retourne les informations d'une maladie précise.
  Future<DiseaseInfo?> getByKey(String diseaseKey) async {
    final diseases = await getAll();

    return diseases[diseaseKey];
  }

  /// Recherche des maladies par nom, culture ou clé.
  Future<List<DiseaseInfo>> search(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final diseases = await getAll();

    return diseases.values.where((disease) {
      return disease.name.toLowerCase().contains(normalizedQuery) ||
          disease.crop.toLowerCase().contains(normalizedQuery) ||
          disease.diseaseKey.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}