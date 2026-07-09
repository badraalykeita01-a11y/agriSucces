import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class SessionService {
static const _currentUserKey = 'current_user';

Future<void> saveUser(UserModel user) async {
final preferences = await SharedPreferences.getInstance();

final userJson = {
  'id': user.id,
  'fullName': user.fullName,
  'phone': user.phone,
  'email': user.email,
  'password': user.password,
  'photo': user.photo,
};

await preferences.setString(
  _currentUserKey,
  jsonEncode(userJson),
);

}

Future<UserModel?> getCurrentUser() async {
final preferences = await SharedPreferences.getInstance();
final rawUser = preferences.getString(_currentUserKey);

if (rawUser == null || rawUser.isEmpty) {
  return null;
}

try {
  final json = Map<String, dynamic>.from(
    jsonDecode(rawUser) as Map,
  );

  return UserModel(
    id: json['id'] as int?,
    fullName: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    password: json['password'] as String? ?? '',
    photo: json['photo'] as String?,
  );
} catch (_) {
  await clearSession();
  return null;
}

}

Future<void> clearSession() async {
final preferences = await SharedPreferences.getInstance();
await preferences.remove(_currentUserKey);
}
}
