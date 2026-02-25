// lib/data/repositories/food_repository.dart
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:shape_up/domain/entities/food.dart';

class FoodRepository {
  final AppDatabase database;
  final SupabaseService supabase;

  FoodRepository({
    required this.database,
    required this.supabase,
  });

  // Получение всех продуктов
  Future<List<Food>> getFoods({String? searchQuery}) async {
    final db = await database.database;
    
    String query = 'SELECT * FROM foods WHERE is_custom = 0';
    List<dynamic> params = [];
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND name LIKE ?';
      params.add('%$searchQuery%');
    }
    
    final result = await db.rawQuery(query, params);
    
    return result.map((json) => Food(
      id: json['id'] as int,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      isCustom: (json['is_custom'] as int) == 1,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    )).toList();
  }

  // Получение пользовательских продуктов
  Future<List<Food>> getCustomFoods(String userId) async {
    final db = await database.database;
    
    final result = await db.query(
      'foods',
      where: 'is_custom = 1 AND user_id = ?',
      whereArgs: [userId],
    );
    
    return result.map((json) => Food(
      id: json['id'] as int,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      isCustom: true,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    )).toList();
  }

  // Добавление пользовательского продукта
  Future<int> addCustomFood(Food food) async {
    final db = await database.database;
    
    return await db.insert('foods', {
      'name': food.name,
      'calories': food.calories,
      'proteins': food.proteins,
      'fats': food.fats,
      'carbs': food.carbs,
      'is_custom': 1,
      'user_id': food.userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Удаление пользовательского продукта
  Future<int> deleteCustomFood(int foodId) async {
    final db = await database.database;
    
    return await db.delete(
      'foods',
      where: 'id = ? AND is_custom = 1',
      whereArgs: [foodId],
    );
  }

  // Получение записей о еде за день
  Future<List<Map<String, dynamic>>> getFoodEntries(
    String userId, 
    DateTime date
  ) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    return await db.rawQuery('''
      SELECT fe.*, f.name, f.calories, f.proteins, f.fats, f.carbs 
      FROM food_entries fe
      JOIN foods f ON fe.food_id = f.id
      WHERE fe.user_id = ? AND fe.date = ?
      ORDER BY 
        CASE fe.meal_type
          WHEN 'breakfast' THEN 1
          WHEN 'lunch' THEN 2
          WHEN 'dinner' THEN 3
          WHEN 'snack' THEN 4
        END
    ''', [userId, dateStr]);
  }

  // Добавление записи о еде
  Future<int> addFoodEntry(Map<String, dynamic> entry) async {
    final db = await database.database;
    
    return await db.insert('food_entries', {
      'user_id': entry['user_id'],
      'date': entry['date'],
      'meal_type': entry['meal_type'],
      'food_id': entry['food_id'],
      'grams': entry['grams'],
      'is_custom_food': entry['is_custom_food'] ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Удаление записи о еде
  Future<int> deleteFoodEntry(int entryId) async {
    final db = await database.database;
    
    return await db.delete(
      'food_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  // Получение записей о воде за день
  Future<int> getTotalWater(String userId, DateTime date) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final result = await db.rawQuery(
      'SELECT SUM(ml) as total FROM water_entries WHERE user_id = ? AND date = ?',
      [userId, dateStr],
    );
    
    return (result.first['total'] as int?) ?? 0;
  }

  // Добавление записи о воде
  Future<int> addWaterEntry(String userId, DateTime date, int ml) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    return await db.insert('water_entries', {
      'user_id': userId,
      'date': dateStr,
      'ml': ml,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Получение измерений тела
  Future<List<Map<String, dynamic>>> getBodyMeasurements(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final db = await database.database;
    
    return await db.query(
      'body_measurements',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );
  }

  // Добавление измерения тела
  Future<int> addBodyMeasurement(Map<String, dynamic> measurement) async {
    final db = await database.database;
    
    return await db.insert('body_measurements', {
      'user_id': measurement['user_id'],
      'date': measurement['date'],
      'weight': measurement['weight'],
      'neck_circumference': measurement['neck_circumference'],
      'waist_circumference': measurement['waist_circumference'],
      'hip_circumference': measurement['hip_circumference'],
      'body_fat_percentage': measurement['body_fat_percentage'],
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}