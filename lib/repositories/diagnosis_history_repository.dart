import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/diagnosis_history_item.dart';

class DiagnosisHistoryRepository {
  static const _storageKey = 'diagnosis_history';

  Future<List<DiagnosisHistoryItem>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final rawList = preferences.getStringList(_storageKey) ?? [];

    final items = <DiagnosisHistoryItem>[];

    for (final rawItem in rawList) {
      try {
        final json = jsonDecode(rawItem) as Map<String, dynamic>;
        items.add(DiagnosisHistoryItem.fromJson(json));
      } catch (_) {
        // Ignore une ancienne entrée invalide au lieu de bloquer l’historique.
      }
    }

    items.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return items;
  }

  Future<void> save(DiagnosisHistoryItem item) async {
    final preferences = await SharedPreferences.getInstance();

    final currentItems = await getAll();

    final updatedItems = [
      item,
      ...currentItems.where((existingItem) => existingItem.id != item.id),
    ];

    updatedItems.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    final rawList = updatedItems
        .map((historyItem) => jsonEncode(historyItem.toJson()))
        .toList();

    await preferences.setStringList(_storageKey, rawList);
  }

  Future<void> remove(String itemId) async {
    final preferences = await SharedPreferences.getInstance();

    final currentItems = await getAll();

    final updatedItems = currentItems
        .where((item) => item.id != itemId)
        .toList();

    final rawList = updatedItems
        .map((historyItem) => jsonEncode(historyItem.toJson()))
        .toList();

    await preferences.setStringList(_storageKey, rawList);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
  Future<void> delete(String itemId) async {
  final preferences = await SharedPreferences.getInstance();

  final currentItems = await getAll();

  final updatedItems = currentItems
      .where((item) => item.id != itemId)
      .toList();

  final rawList = updatedItems
      .map((item) => jsonEncode(item.toJson()))
      .toList();

  await preferences.setStringList(_storageKey, rawList);
}
}