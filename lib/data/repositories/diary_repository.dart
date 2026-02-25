// lib/data/repositories/diary_repository.dart
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/domain/entities/food_entry.dart';
import 'package:shape_up/domain/entities/water_entry.dart';

class DiaryRepository {
  final AppDatabase database;

  DiaryRepository({
    required this.database,
  });

  // Food Entries
  Future<List<FoodEntry>> getFoodEntries(String userId, DateTime date) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'food_entries',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      orderBy: 'created_at ASC',
    );
    
    return result.map((json) => FoodEntry.fromJson(json)).toList();
  }

  Future<Map<String, List<FoodEntry>>> getFoodEntriesByMeal(
    String userId, 
    DateTime date
  ) async {
    final entries = await getFoodEntries(userId, date);
    
    final result = {
      'breakfast': <FoodEntry>[],
      'lunch': <FoodEntry>[],
      'dinner': <FoodEntry>[],
      'snack': <FoodEntry>[],
    };
    
    for (var entry in entries) {
      result[entry.mealType]?.add(entry);
    }
    
    return result;
  }

  Future<int> addFoodEntry(FoodEntry entry) async {
    final db = await database.database;
    
    return await db.insert('food_entries', entry.toJson());
  }

  Future<int> updateFoodEntry(FoodEntry entry) async {
    final db = await database.database;
    
    return await db.update(
      'food_entries',
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteFoodEntry(int entryId) async {
    final db = await database.database;
    
    return await db.delete(
      'food_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  Future<Map<String, double>> getDailyNutrition(String userId, DateTime date) async {
    final entries = await getFoodEntries(userId, date);
    
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;
    
    for (var entry in entries) {
      calories += entry.calories;
      proteins += entry.proteins;
      fats += entry.fats;
      carbs += entry.carbs;
    }
    
    return {
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
    };
  }

  // Water Entries
  Future<List<WaterEntry>> getWaterEntries(String userId, DateTime date) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'water_entries',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      orderBy: 'created_at ASC',
    );
    
    return result.map((json) => WaterEntry.fromJson(json)).toList();
  }

  Future<int> getTotalWater(String userId, DateTime date) async {
    final entries = await getWaterEntries(userId, date);
    int total = 0;
    for (var entry in entries) {
      total += entry.ml;
    }
    return total;
  }

  Future<int> addWaterEntry(WaterEntry entry) async {
    final db = await database.database;
    
    return await db.insert('water_entries', entry.toJson());
  }

  Future<int> deleteWaterEntry(int entryId) async {
    final db = await database.database;
    
    return await db.delete(
      'water_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }
}