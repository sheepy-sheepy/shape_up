// lib/data/repositories/body_repository.dart
import 'package:flutter/foundation.dart';
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:shape_up/domain/entities/body_measurement.dart';

class BodyRepository {
  final AppDatabase database;

  BodyRepository({
    required this.database,
  });

  Future<List<BodyMeasurement>> getMeasurements(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database.database;

    String where = 'user_id = ?';
    List<dynamic> args = [userId];

    if (startDate != null) {
      where += ' AND date >= ?';
      args.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      where += ' AND date <= ?';
      args.add(endDate.toIso8601String().split('T')[0]);
    }

    final result = await db.query(
      'body_measurements',
      where: where,
      whereArgs: args,
      orderBy: 'date ASC',
    );

    return result.map((json) => BodyMeasurement.fromJson(json)).toList();
  }

  Future<BodyMeasurement?> getMeasurementForDate(
      String userId, DateTime date) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final result = await db.query(
      'body_measurements',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
    );

    if (result.isEmpty) return null;
    return BodyMeasurement.fromJson(result.first);
  }

  Future<bool> hasMeasurementForDate(String userId, DateTime date) async {
    final measurement = await getMeasurementForDate(userId, date);
    return measurement != null;
  }

  Future<int> addMeasurement(BodyMeasurement measurement) async {
    final db = await database.database;

    final map = {
      'user_id': measurement.userId,
      'date': measurement.date.toIso8601String().split('T')[0],
      'weight': measurement.weight,
      'neck_circumference': measurement.neckCircumference,
      'waist_circumference': measurement.waistCircumference,
      'hip_circumference': measurement.hipCircumference,
      'body_fat_percentage': measurement.bodyFatPercentage,
      'created_at': measurement.createdAt.toIso8601String(),
    };

    debugPrint('Adding measurement: $map');

    return await db.insert('body_measurements', map);
  }

  Future<int> updateMeasurement(BodyMeasurement measurement) async {
    final db = await database.database;

    return await db.update(
      'body_measurements',
      {
        'weight': measurement.weight,
        'neck_circumference': measurement.neckCircumference,
        'waist_circumference': measurement.waistCircumference,
        'hip_circumference': measurement.hipCircumference,
        'body_fat_percentage': measurement.bodyFatPercentage,
      },
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> getMeasurementsForChart(
    String userId,
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final measurements = await getMeasurements(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    final result = {
      'weight': <Map<String, dynamic>>[],
      'neck': <Map<String, dynamic>>[],
      'waist': <Map<String, dynamic>>[],
      'hip': <Map<String, dynamic>>[],
      'bodyFat': <Map<String, dynamic>>[],
    };

    for (var m in measurements) {
      if (m.weight != null) {
        result['weight']!.add({
          'date': m.date,
          'value': m.weight,
        });
      }
      if (m.neckCircumference != null) {
        result['neck']!.add({
          'date': m.date,
          'value': m.neckCircumference,
        });
      }
      if (m.waistCircumference != null) {
        result['waist']!.add({
          'date': m.date,
          'value': m.waistCircumference,
        });
      }
      if (m.hipCircumference != null) {
        result['hip']!.add({
          'date': m.date,
          'value': m.hipCircumference,
        });
      }
      if (m.bodyFatPercentage != null) {
        result['bodyFat']!.add({
          'date': m.date,
          'value': m.bodyFatPercentage,
        });
      }
    }

    return result;
  }

  Future<void> syncMeasurementsFromSupabase(String userId) async {
    try {
      // Получаем все измерения пользователя из Supabase
      final response = await SupabaseService.supabase
          .from('body_measurements')
          .select()
          .eq('user_id', userId)
          .order('date');

      debugPrint('📥 Found ${response.length} measurements in Supabase');

      if (response.isEmpty) return;

      final db = await database.database;

      // Для каждого измерения из Supabase
      for (var measurementJson in response) {
        // Проверяем, есть ли уже такое измерение в локальной БД
        final existing = await db.query(
          'body_measurements',
          where: 'user_id = ? AND date = ?',
          whereArgs: [userId, measurementJson['date']],
        );

        if (existing.isEmpty) {
          // Если нет, добавляем
          await db.insert('body_measurements', {
            'user_id': userId,
            'date': measurementJson['date'],
            'weight': measurementJson['weight'],
            'neck_circumference': measurementJson['neck_circumference'],
            'waist_circumference': measurementJson['waist_circumference'],
            'hip_circumference': measurementJson['hip_circumference'],
            'body_fat_percentage': measurementJson['body_fat_percentage'],
            'created_at': measurementJson['created_at'],
          });
          debugPrint(
              '✅ Added measurement for date: ${measurementJson['date']}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error syncing measurements: $e');
    }
  }
}
