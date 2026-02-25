// lib/data/repositories/app_repository_provider.dart
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:shape_up/data/repositories/auth_repository.dart';
import 'package:shape_up/data/repositories/food_repository.dart';
import 'package:shape_up/data/repositories/diary_repository.dart';
import 'package:shape_up/data/repositories/body_repository.dart';
import 'package:shape_up/data/repositories/photo_repository.dart';

class AppRepositoryProvider {
  static late final AuthRepository auth;
  static late final FoodRepository food;
  static late final DiaryRepository diary;
  static late final BodyRepository body;
  static late final PhotoRepository photo;

  static Future<void> initialize() async {
    final database = AppDatabase();
    
    auth = AuthRepository(
      database: database,
      supabase: SupabaseService(),
    );
    
    food = FoodRepository(database: database);
    diary = DiaryRepository(database: database);
    body = BodyRepository(database: database);
    photo = PhotoRepository(database: database);
  }
}