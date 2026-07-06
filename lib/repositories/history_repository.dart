import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/diagnosis_history_item.dart';

class HistoryRepository {
  static const _storageKey = 'diagnosis_history';

  Future<List<DiagnosisHistoryItem>> getAll() async {
    final preferences = await SharedPreferences.getInstance();

    final rawHistory = preferences.getString(_storageKey);

    if (rawHistory == null || rawHistory.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawHistory) as List<dynamic>;

    final history = decoded
        .map(
          (item) => DiagnosisHistoryItem.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return history;
  }

  Future<void> save(DiagnosisHistoryItem item) async {
    final history = await getAll();

    history.removeWhere((element) => element.id == item.id);

    history.insert(0, item);

    await _saveAll(history);
  }

  Future<void> delete(String id) async {
    final history = await getAll();

    history.removeWhere((item) => item.id == id);

    await _saveAll(history);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  Future<void> _saveAll(List<DiagnosisHistoryItem> history) async {
    final preferences = await SharedPreferences.getInstance();

    final rawHistory = jsonEncode(
      history.map((item) => item.toJson()).toList(),
    );

    await preferences.setString(_storageKey, rawHistory);
  }
}