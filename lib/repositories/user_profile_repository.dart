import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
static const _storageKey = 'user_profile';

Future<UserProfile> getProfile() async {
final preferences = await SharedPreferences.getInstance();
final rawProfile = preferences.getString(_storageKey);

if (rawProfile == null || rawProfile.isEmpty) {
  return UserProfile.empty();
}

final json = jsonDecode(rawProfile) as Map<String, dynamic>;
return UserProfile.fromJson(json);

}

Future<void> saveProfile(UserProfile profile) async {
final preferences = await SharedPreferences.getInstance();

await preferences.setString(
  _storageKey,
  jsonEncode(profile.toJson()),
);

}
}
