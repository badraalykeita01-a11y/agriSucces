import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// Inscription
  Future<int> register(UserModel user) async {
    final Database db = await _databaseHelper.database;

    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Connexion
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return UserModel.fromMap(result.first);
  }

  /// Vérifie si un email existe déjà
  Future<bool> emailExists(String email) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Récupérer un utilisateur
  Future<UserModel?> getUser(int id) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return UserModel.fromMap(result.first);
  }

  /// Modifier un utilisateur
  Future<int> updateUser(UserModel user) async {
    final Database db = await _databaseHelper.database;

    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Supprimer un utilisateur
  Future<int> deleteUser(int id) async {
    final Database db = await _databaseHelper.database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}