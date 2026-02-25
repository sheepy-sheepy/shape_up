// lib/data/datasources/local/app_database.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  AppDatabase();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Таблица users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT,
        birth_date TEXT,
        gender TEXT,
        height REAL,
        weight REAL,
        neck_circumference REAL,
        waist_circumference REAL,
        hip_circumference REAL,
        goal TEXT,
        activity_level TEXT,
        calorie_deficit INTEGER,
        calorie_surplus INTEGER,
        created_at TEXT NOT NULL,
        has_completed_initial_params INTEGER DEFAULT 0,
        last_sync TEXT
      )
    ''');

    // Таблица foods
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        fats REAL NOT NULL,
        carbs REAL NOT NULL,
        is_custom INTEGER DEFAULT 0,
        user_id TEXT,
        created_at TEXT,
        is_recipe INTEGER DEFAULT 0,
        recipe_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Таблица recipes
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        user_id TEXT NOT NULL,
        total_calories REAL,
        total_proteins REAL,
        total_fats REAL,
        total_carbs REAL,
        total_grams REAL,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Таблица recipe_ingredients
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        food_id INTEGER NOT NULL,
        grams REAL NOT NULL,
        is_custom_food INTEGER DEFAULT 0,
        food_name TEXT,
        food_calories REAL,
        food_proteins REAL,
        food_fats REAL,
        food_carbs REAL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE
      )
    ''');

    // Таблица food_entries
    await db.execute('''
      CREATE TABLE food_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        food_id INTEGER NOT NULL,
        grams REAL NOT NULL,
        is_custom_food INTEGER DEFAULT 0,
        is_recipe INTEGER DEFAULT 0,
        recipe_id INTEGER,
        created_at TEXT NOT NULL,
        food_name TEXT,
        food_calories REAL,
        food_proteins REAL,
        food_fats REAL,
        food_carbs REAL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE
      )
    ''');

    // Таблица body_measurements
    await db.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        neck_circumference REAL,
        waist_circumference REAL,
        hip_circumference REAL,
        body_fat_percentage REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Таблица photos
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        front_photo TEXT,
        back_photo TEXT,
        left_side_photo TEXT,
        right_side_photo TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Таблица water_entries
    await db.execute('''
      CREATE TABLE water_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        ml INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Таблица sync_queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        record_id INTEGER,
        data TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    // Создаем индексы для оптимизации
    await db.execute('CREATE INDEX idx_food_entries_user_date ON food_entries(user_id, date)');
    await db.execute('CREATE INDEX idx_body_measurements_user_date ON body_measurements(user_id, date)');
    await db.execute('CREATE INDEX idx_photos_user_date ON photos(user_id, date)');
    await db.execute('CREATE INDEX idx_water_entries_user_date ON water_entries(user_id, date)');
    await db.execute('CREATE INDEX idx_foods_user_id ON foods(user_id) WHERE is_custom = 1');
    
    debugPrint('✅ Database schema created successfully');
  }

  static Future<void> init() async {
    await instance.database;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}