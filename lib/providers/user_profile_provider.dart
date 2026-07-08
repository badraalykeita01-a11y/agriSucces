import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProfileNotifier(repository);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final UserProfileRepository _repository;

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();

      final profile = await _repository.getProfile();

      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Initialise ou actualise le profil à partir du compte connecté.
  ///
  /// La localisation et la photo existantes sont conservées.
  Future<void> syncFromUser(UserModel user) async {
    try {
      final currentProfile = state.valueOrNull ??
          await _repository.getProfile();

      final updatedProfile = currentProfile.copyWith(
        fullName: user.fullName,
        phone: user.phone,
        profileImagePath: user.photo ?? currentProfile.profileImagePath,
      );

      await _repository.saveProfile(updatedProfile);

      state = AsyncValue.data(updatedProfile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> save(UserProfile profile) async {
    try {
      await _repository.saveProfile(profile);

      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}