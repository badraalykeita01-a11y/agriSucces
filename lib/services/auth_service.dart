import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  AuthService();

  final AuthRepository _repository = AuthRepository();

  /// ==========================
  /// INSCRIPTION
  /// ==========================
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    String? photo,
  }) async {
    // Nettoyage des données
    fullName = fullName.trim();
    phone = phone.trim();
    email = email.trim().toLowerCase();

    // Validation
    if (fullName.isEmpty) {
      throw Exception("Veuillez saisir votre nom.");
    }

    if (phone.isEmpty) {
      throw Exception("Veuillez saisir votre numéro.");
    }

    if (email.isEmpty) {
      throw Exception("Veuillez saisir votre adresse e-mail.");
    }

    if (!email.contains("@")) {
      throw Exception("Adresse e-mail invalide.");
    }

    if (password.length < 6) {
      throw Exception(
        "Le mot de passe doit contenir au moins 6 caractères.",
      );
    }

    final exists = await _repository.emailExists(email);

    if (exists) {
      throw Exception(
        "Cette adresse e-mail est déjà utilisée.",
      );
    }

    final user = UserModel(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      photo: photo,
    );

    final id = await _repository.register(user);

    return user.copyWith(id: id);
  }

  /// ==========================
  /// CONNEXION
  /// ==========================
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    email = email.trim().toLowerCase();

    if (email.isEmpty) {
      throw Exception("Veuillez saisir votre e-mail.");
    }

    if (password.isEmpty) {
      throw Exception("Veuillez saisir votre mot de passe.");
    }

    final user = await _repository.login(
      email: email,
      password: password,
    );

    if (user == null) {
      throw Exception(
        "Adresse e-mail ou mot de passe incorrect.",
      );
    }

    return user;
  }

  /// ==========================
  /// MODIFIER LE PROFIL
  /// ==========================
  Future<void> updateUser(UserModel user) async {
    await _repository.updateUser(user);
  }

  /// ==========================
  /// SUPPRIMER LE COMPTE
  /// ==========================
  Future<void> deleteUser(int id) async {
    await _repository.deleteUser(id);
  }

  /// ==========================
  /// RÉCUPÉRER UN UTILISATEUR
  /// ==========================
  Future<UserModel?> getUser(int id) async {
    return _repository.getUser(id);
  }
}