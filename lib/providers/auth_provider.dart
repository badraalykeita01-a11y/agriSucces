import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
return AuthService();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
return SessionService();
});

final currentUserProvider = StateProvider<UserModel?>((ref) {
return null;
});

final authSessionProvider =
StateNotifierProvider<AuthSessionNotifier, AsyncValue<UserModel?>>((ref) {
return AuthSessionNotifier(
ref.read(sessionServiceProvider),
ref.read(currentUserProvider.notifier),
);
});

class AuthSessionNotifier extends StateNotifier<AsyncValue<UserModel?>> {
AuthSessionNotifier(
this._sessionService,
this._currentUserNotifier,
) : super(const AsyncValue.loading()) {
restoreSession();
}

final SessionService _sessionService;
final StateController<UserModel?> _currentUserNotifier;

Future<void> restoreSession() async {
try {
state = const AsyncValue.loading();

  final user = await _sessionService.getCurrentUser();

  _currentUserNotifier.state = user;
  state = AsyncValue.data(user);
} catch (e, stackTrace) {
  _currentUserNotifier.state = null;
  state = AsyncValue.error(e, stackTrace);
}

}

Future<void> login(UserModel user) async {
await _sessionService.saveUser(user);

_currentUserNotifier.state = user;
state = AsyncValue.data(user);

}

Future<void> logout() async {
await _sessionService.clearSession();

_currentUserNotifier.state = null;
state = const AsyncValue.data(null);

}
}
