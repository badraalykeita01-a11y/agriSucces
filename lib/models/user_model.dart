class UserModel {
  final int? id;
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String? photo;

  const UserModel({
    this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    this.photo,
  });

  UserModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? photo,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'photo': photo,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      photo: map['photo'] as String?,
    );
  }
}