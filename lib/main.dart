// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Initialize localization for Russian
  await initializeDateFormatting('ru', null);

  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize local database
  await AppDatabase.init();

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
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/initial-params': (context) => const InitialParamsPage(),
          '/main': (context) => const MainPage(),
          '/settings': (context) => const SettingsPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/food-search') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FoodSearchPage(
                mealType: args['mealType'],
                date: args['date'],
              ),
            );
          }
          if (settings.name == '/food-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FoodDetailPage(
                food: args['food'],
                mealType: args['mealType'],
                date: args['date'],
              ),
            );
          }
          if (settings.name == '/add-food') {
            return MaterialPageRoute(
              builder: (context) => const AddFoodPage(),
            );
          }
          if (settings.name == '/add-recipe') {
            return MaterialPageRoute(
              builder: (context) => const AddRecipePage(),
            );
          }
          return null;
        },
      ),
    );
  }
}
