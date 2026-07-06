import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/diagnosis_history_item.dart';
import '../repositories/diagnosis_history_repository.dart';

final diagnosisHistoryRepositoryProvider =
    Provider<DiagnosisHistoryRepository>((ref) {
  return DiagnosisHistoryRepository();
});

final diagnosisHistoryProvider = StateNotifierProvider<
    DiagnosisHistoryNotifier, AsyncValue<List<DiagnosisHistoryItem>>>(
  (ref) {
    final repository = ref.watch(diagnosisHistoryRepositoryProvider);
    return DiagnosisHistoryNotifier(repository);
  },
);

class DiagnosisHistoryNotifier
    extends StateNotifier<AsyncValue<List<DiagnosisHistoryItem>>> {
  DiagnosisHistoryNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    load();
  }

  final DiagnosisHistoryRepository _repository;

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();

      final items = await _repository.getAll();

      items.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      state = AsyncValue.data(items);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> add(DiagnosisHistoryItem item) async {
    try {
      await _repository.save(item);

      final currentItems = state.valueOrNull ?? [];

      final updatedItems = [
        item,
        ...currentItems.where((element) => element.id != item.id),
      ];

      updatedItems.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      state = AsyncValue.data(updatedItems);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> remove(String itemId) async {
    try {
      await _repository.delete(itemId);

      final currentItems = state.valueOrNull ?? [];

      state = AsyncValue.data(
        currentItems.where((item) => item.id != itemId).toList(),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clear() async {
    try {
      await _repository.clear();
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}