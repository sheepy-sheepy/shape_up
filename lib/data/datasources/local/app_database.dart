import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shape_up.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT,
        birthDate TEXT,
        gender TEXT,
        height REAL,
        weight REAL,
        neckCircumference REAL,
        waistCircumference REAL,
        hipCircumference REAL,
        goal TEXT,
        activityLevel TEXT,
        calorieDeficit INTEGER,
        calorieSurplus INTEGER,
        createdAt TEXT NOT NULL,
        hasCompletedInitialParams INTEGER DEFAULT 0,
        lastSync TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        fats REAL NOT NULL,
        carbs REAL NOT NULL,
        isCustom INTEGER DEFAULT 0,
        userId TEXT,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        userId TEXT NOT NULL,
        totalCalories REAL,
        totalProteins REAL,
        totalFats REAL,
        totalCarbs REAL,
        totalGrams REAL,
        createdAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeId INTEGER NOT NULL,
        foodId INTEGER NOT NULL,
        grams REAL NOT NULL,
        isCustomFood INTEGER DEFAULT 0,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (foodId) REFERENCES foods (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE food_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        foodId INTEGER NOT NULL,
        grams REAL NOT NULL,
        isCustomFood INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (foodId) REFERENCES foods (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        neckCircumference REAL,
        waistCircumference REAL,
        hipCircumference REAL,
        bodyFatPercentage REAL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        frontPhoto TEXT,
        backPhoto TEXT,
        leftSidePhoto TEXT,
        rightSidePhoto TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE water_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        ml INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
  }

  static Future<void> init() async {
    await instance.database;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}