class UserProfile {
const UserProfile({
required this.fullName,
required this.phone,
required this.location,
required this.profileImagePath,
});

final String fullName;
final String phone;
final String location;
final String? profileImagePath;

factory UserProfile.empty() {
return const UserProfile(
fullName: '',
phone: '',
location: '',
profileImagePath: null,
);
}

UserProfile copyWith({
String? fullName,
String? phone,
String? location,
String? profileImagePath,
}) {
return UserProfile(
fullName: fullName ?? this.fullName,
phone: phone ?? this.phone,
location: location ?? this.location,
profileImagePath: profileImagePath ?? this.profileImagePath,
);
}

Map<String, dynamic> toJson() {
return {
'fullName': fullName,
'phone': phone,
'location': location,
'profileImagePath': profileImagePath,
};
}

factory UserProfile.fromJson(Map<String, dynamic> json) {
return UserProfile(
fullName: json['fullName'] as String? ?? '',
phone: json['phone'] as String? ?? '',
location: json['location'] as String? ?? '',
profileImagePath: json['profileImagePath'] as String?,
);
}

bool get isComplete {
return fullName.trim().isNotEmpty;
}
}
