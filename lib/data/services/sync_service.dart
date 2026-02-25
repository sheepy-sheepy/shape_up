// lib/data/services/sync_service.dart
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  final AppDatabase database;
  final SupabaseService supabase;

  SyncService({
    required this.database,
    required this.supabase,
  });

  // Проверка интернет-соединения
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Добавление операции в очередь синхронизации
  Future<void> addToSyncQueue({
    required String userId,
    required String tableName,
    required String operation,
    int? recordId,
    Map<String, dynamic>? data,
  }) async {
    final db = await database.database;
    
    await db.insert('sync_queue', {
      'user_id': userId,
      'table_name': tableName,
      'operation': operation,
      'record_id': recordId,
      'data': data != null ? data.toString() : null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Синхронизация данных
  Future<void> syncData(String userId) async {
    if (!await hasInternetConnection()) {
      return;
    }

    final db = await database.database;
    
    // Получаем несинхронизированные операции
    final pendingOps = await db.query(
      'sync_queue',
      where: 'user_id = ? AND synced_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );

    for (var op in pendingOps) {
      try {
        await _syncOperation(op);
        
        // Отмечаем как синхронизированное
        await db.update(
          'sync_queue',
          {'synced_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [op['id']],
        );
      } catch (e) {
        print('Sync error for operation ${op['id']}: $e');
      }
    }
  }

  Future<void> _syncOperation(Map<String, dynamic> operation) async {
    final tableName = operation['table_name'] as String;
    final opType = operation['operation'] as String;
    
    switch ('$tableName:$opType') {
      case 'food_entries:INSERT':
        // Синхронизация записи о еде
        await SupabaseService.addFoodEntry(
          Map<String, dynamic>.from(operation['data'] as Map),
        );
        break;
      case 'water_entries:INSERT':
        // Синхронизация записи о воде
        final data = Map<String, dynamic>.from(operation['data'] as Map);
        await SupabaseService.addWaterEntry(
          data['ml'] as int,
          DateTime.parse(data['date'] as String),
        );
        break;
      // Добавить другие типы операций
    }
  }

  // Загрузка данных с сервера
  Future<void> pullData(String userId) async {
    if (!await hasInternetConnection()) {
      return;
    }

    // Загружаем продукты
    await _pullFoods(userId);
    
    // Загружаем записи о еде
    await _pullFoodEntries(userId);
    
    // Загружаем записи о воде
    await _pullWaterEntries(userId);
    
    // Загружаем измерения
    await _pullMeasurements(userId);
  }

  Future<void> _pullFoods(String userId) async {
    final remoteFoods = await SupabaseService.getFoods('');
    
    final db = await database.database;
    
    for (var food in remoteFoods) {
      await db.insert(
        'foods',
        {
          'id': food['id'],
          'name': food['name'],
          'calories': food['calories'],
          'proteins': food['proteins'],
          'fats': food['fats'],
          'carbs': food['carbs'],
          'is_custom': food['is_custom'] ? 1 : 0,
          'user_id': food['user_id'],
          'created_at': food['created_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _pullFoodEntries(String userId) async {
    final today = DateTime.now();
    final entries = await SupabaseService.getFoodEntries(today);
    
    final db = await database.database;
    
    for (var entry in entries) {
      await db.insert(
        'food_entries',
        {
          'id': entry['id'],
          'user_id': entry['user_id'],
          'date': entry['date'],
          'meal_type': entry['meal_type'],
          'food_id': entry['food_id'],
          'grams': entry['grams'],
          'is_custom_food': entry['is_custom_food'] ? 1 : 0,
          'created_at': entry['created_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _pullWaterEntries(String userId) async {
    final today = DateTime.now();
    final total = await SupabaseService.getTotalWater(today);
    // Сохраняем в локальную БД
  }

  Future<void> _pullMeasurements(String userId) async {
    // Загружаем измерения
  }
}