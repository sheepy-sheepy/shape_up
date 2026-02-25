// lib/data/repositories/auth_repository.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:shape_up/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AppDatabase database;
  final SupabaseService supabase;

  AuthRepository({
    required this.database,
    required this.supabase,
  });

  Future<User?> getCurrentUser() async {
    final supabaseUser = SupabaseService.getCurrentUser();
    if (supabaseUser == null) return null;

    return await getUserById(supabaseUser.id);
  }

  Future<User?> getUserById(String userId) async {
    final db = await database.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isEmpty) return null;

    return User.fromJson(result.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) return null;

    return User.fromJson(result.first);
  }

  Future<User> createUser(User user) async {
    final db = await database.database;

    await db.insert(
      'users',
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return user;
  }

  Future<User> updateUser(User user) async {
    final db = await database.database;

    final map = {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'birth_date': user.birthDate?.toIso8601String(),
      'gender': user.gender,
      'height': user.height,
      'weight': user.weight,
      'neck_circumference': user.neckCircumference,
      'waist_circumference': user.waistCircumference,
      'hip_circumference': user.hipCircumference,
      'goal': user.goal,
      'activity_level': user.activityLevel,
      'calorie_deficit': user.calorieDeficit,
      'calorie_surplus': user.calorieSurplus,
      'created_at': user.createdAt.toIso8601String(),
      'has_completed_initial_params': user.hasCompletedInitialParams ? 1 : 0,
    };

    debugPrint('Updating user with map: $map');

    await db.update(
      'users',
      map,
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return user;
  }

  // Вспомогательный метод для конвертации User в Map с правильными именами колонок
  Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'birth_date': user.birthDate?.toIso8601String(),
      'gender': user.gender,
      'height': user.height,
      'weight': user.weight,
      'neck_circumference': user.neckCircumference,
      'waist_circumference': user.waistCircumference,
      'hip_circumference': user.hipCircumference,
      'goal': user.goal,
      'activity_level': user.activityLevel,
      'calorie_deficit': user.calorieDeficit,
      'calorie_surplus': user.calorieSurplus,
      'created_at': user.createdAt.toIso8601String(),
      'has_completed_initial_params':
          user.hasCompletedInitialParams ? 1 : 0, // SQLite не поддерживает bool
    };
  }

  Future<void> deleteUser(String userId) async {
    final db = await database.database;

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> hasCompletedInitialParams(String userId) async {
    final user = await getUserById(userId);
    return user?.hasCompletedInitialParams ?? false;
  }

  Future<void> setInitialParamsCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('initial_params_$userId', true);
  }

  Future<bool> getInitialParamsCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('initial_params_$userId') ?? false;
  }
}
