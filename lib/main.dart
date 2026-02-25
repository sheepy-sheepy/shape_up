// lib/main.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shape_up/core/theme/app_theme.dart';
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/splash/splash_page.dart';
import 'package:shape_up/presentation/pages/auth/login_page.dart';
import 'package:shape_up/presentation/pages/auth/register_page.dart';
import 'package:shape_up/presentation/pages/onboarding/initial_params_page.dart';
import 'package:shape_up/presentation/pages/main/main_page.dart';
import 'package:shape_up/presentation/pages/settings/settings_page.dart';
import 'package:shape_up/presentation/pages/food/food_search_page.dart';
import 'package:shape_up/presentation/pages/food/food_detail_page.dart';
import 'package:shape_up/presentation/pages/food/add_food_page.dart';
import 'package:shape_up/presentation/pages/food/add_recipe_page.dart';

Future<void> _resetDatabase() async {
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_app.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      debugPrint('✅ Old database deleted');
    }
  } catch (e) {
    debugPrint('Error deleting database: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    // Сбрасываем БД перед инициализацией
  await _resetDatabase();

// Initialize localization for Russian
  try {
    await initializeDateFormatting('ru', null);
  } catch (e) {
    debugPrint('Ошибка при инициализации языкового стандарта: $e');
  }

  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize local database
  await AppDatabase.init();

  await AppRepositoryProvider.initialize();

  // Load initial foods from CSV
  await SupabaseService.loadInitialFoods();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'Shape Up',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ru', 'RU'),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashPage());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterPage());
            case '/initial-params':
              return MaterialPageRoute(
                  builder: (_) => const InitialParamsPage());
            case '/main':
              return MaterialPageRoute(builder: (_) => const MainPage());
            case '/settings':
              return MaterialPageRoute(builder: (_) => const SettingsPage());
            case '/food-search':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => FoodSearchPage(
                  mealType: args['mealType'],
                  date: args['date'],
                ),
              );
            case '/food-detail':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => FoodDetailPage(
                  food: args['food'],
                  mealType: args['mealType'],
                  date: args['date'],
                ),
              );
            case '/add-food':
              return MaterialPageRoute(builder: (_) => const AddFoodPage());
            case '/add-recipe':
              return MaterialPageRoute(builder: (_) => const AddRecipePage());
            default:
              return null;
          }
        },
      ),
    );
  }
}
