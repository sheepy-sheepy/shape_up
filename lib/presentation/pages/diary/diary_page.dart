import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/food_entry.dart';
import 'package:shape_up/domain/entities/water_entry.dart';
import 'package:shape_up/domain/entities/user.dart';
import 'package:shape_up/domain/usecases/calculate_nutrition.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/food/food_search_page.dart';
import 'package:shape_up/presentation/pages/food/food_detail_page.dart';
import 'package:shape_up/presentation/widgets/meal_section.dart';
import 'package:shape_up/presentation/widgets/water_tracker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  
  User? _user;
  Map<String, double> _norms = {};
  Map<String, double> _consumed = {};
  Map<String, List<FoodEntry>> _meals = {};
  int _waterConsumed = 0;
  
  final _calculator = CalculateNutrition();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;
      
      _user = authState.user;
      
      // Загружаем записи о еде
      final entries = await AppRepositoryProvider.diary.getFoodEntriesByMeal(
        authState.user!.id,
        _selectedDate,
      );
      
      // Загружаем воду
      final water = await AppRepositoryProvider.diary.getTotalWater(
        authState.user!.id,
        _selectedDate,
      );
      
      // Рассчитываем consumed
      final daily = await AppRepositoryProvider.diary.getDailyNutrition(
        authState.user!.id,
        _selectedDate,
      );
      
      // Рассчитываем нормы
      _norms = _calculateNorms(authState.user!);
      
      setState(() {
        _meals = entries;
        _consumed = daily;
        _waterConsumed = water;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  Map<String, double> _calculateNorms(User user) {
    if (user.birthDate == null || 
        user.height == null || 
        user.weight == null || 
        user.gender == null || 
        user.activityLevel == null || 
        user.goal == null) {
      return {
        'calories': 2000,
        'proteins': 150,
        'fats': 50,
        'carbs': 250,
        'water': 2000,
      };
    }
    
    final age = _calculator.calculateAge(user.birthDate!);
    
    final dci = _calculator.calculateDCI(
      weight: user.weight!,
      height: user.height!,
      age: age,
      gender: user.gender!,
      activityLevel: user.activityLevel!,
    );
    
    final calories = _calculator.calculateCalorieNorm(
      dci: dci,
      goal: user.goal!,
      deficit: user.calorieDeficit,
      surplus: user.calorieSurplus,
    );
    
    final macros = _calculator.calculateMacros(
      calories: calories,
      goal: user.goal!,
    );
    
    final water = _calculator.calculateWaterNorm(
      weight: user.weight!,
      gender: user.gender!,
      activityLevel: user.activityLevel!,
    );
    
    return {
      'calories': calories,
      'proteins': macros['proteins']!,
      'fats': macros['fats']!,
      'carbs': macros['carbs']!,
      'water': water,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildDateSelector(),
            ),
            SliverToBoxAdapter(
              child: _buildNutritionSummary(),
            ),
            SliverToBoxAdapter(
              child: WaterTracker(
                waterNorm: _norms['water']?.toInt() ?? 2000,
                waterConsumed: _waterConsumed,
                onWaterAdded: _addWater,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Завтрак',
                entries: _meals['breakfast'] ?? [],
                mealSummary: _getMealSummary(_meals['breakfast'] ?? []),
                onAddPressed: () => _navigateToFoodSearch('breakfast'),
                onDeleteEntry: _deleteFoodEntry,
                onEditEntry: _editFoodEntry,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Обед',
                entries: _meals['lunch'] ?? [],
                mealSummary: _getMealSummary(_meals['lunch'] ?? []),
                onAddPressed: () => _navigateToFoodSearch('lunch'),
                onDeleteEntry: _deleteFoodEntry,
                onEditEntry: _editFoodEntry,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Ужин',
                entries: _meals['dinner'] ?? [],
                mealSummary: _getMealSummary(_meals['dinner'] ?? []),
                onAddPressed: () => _navigateToFoodSearch('dinner'),
                onDeleteEntry: _deleteFoodEntry,
                onEditEntry: _editFoodEntry,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Перекус',
                entries: _meals['snack'] ?? [],
                mealSummary: _getMealSummary(_meals['snack'] ?? []),
                onAddPressed: () => _navigateToFoodSearch('snack'),
                onDeleteEntry: _deleteFoodEntry,
                onEditEntry: _editFoodEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _getMealSummary(List<FoodEntry> entries) {
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;
    double grams = 0;
    
    for (var entry in entries) {
      calories += entry.calories;
      proteins += entry.proteins;
      fats += entry.fats;
      carbs += entry.carbs;
      grams += entry.grams;
    }
    
    return {
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'grams': grams,
    };
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _loadData();
            },
          ),
          Column(
            children: [
              Text(
                _formatDayOfWeek(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                ? () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                    _loadData();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  String _formatDayOfWeek(DateTime date) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildNutritionSummary() {
    final calorieDiff = _consumed['calories']! - _norms['calories']!;
    final proteinDiff = _consumed['proteins']! - _norms['proteins']!;
    final fatDiff = _consumed['fats']! - _norms['fats']!;
    final carbDiff = _consumed['carbs']! - _norms['carbs']!;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientColumn(
                  'Калории',
                  '${_consumed['calories']!.toInt()}',
                  '/ ${_norms['calories']!.toInt()}',
                  calorieDiff > 0 ? Colors.red : Colors.green,
                  calorieDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  calorieDiff.abs().toInt(),
                ),
                _buildNutrientColumn(
                  'Белки',
                  '${_consumed['proteins']!.toInt()}г',
                  '/ ${_norms['proteins']!.toInt()}г',
                  proteinDiff > 0 ? Colors.red : Colors.green,
                  proteinDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  proteinDiff.abs().toInt(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientColumn(
                  'Жиры',
                  '${_consumed['fats']!.toInt()}г',
                  '/ ${_norms['fats']!.toInt()}г',
                  fatDiff > 0 ? Colors.red : Colors.green,
                  fatDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  fatDiff.abs().toInt(),
                ),
                _buildNutrientColumn(
                  'Углеводы',
                  '${_consumed['carbs']!.toInt()}г',
                  '/ ${_norms['carbs']!.toInt()}г',
                  carbDiff > 0 ? Colors.red : Colors.green,
                  carbDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  carbDiff.abs().toInt(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(
    String label,
    String value,
    String norm,
    Color diffColor,
    IconData diffIcon,
    int diff,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              norm,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(diffIcon, color: diffColor, size: 16),
            const SizedBox(width: 2),
            Text(
              diff.toString(),
              style: TextStyle(color: diffColor, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addWater(int ml) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;
      
      await AppRepositoryProvider.diary.addWaterEntry(
        WaterEntry(
          userId: authState.user!.id,
          date: _selectedDate,
          ml: ml,
          createdAt: DateTime.now(),
        ),
      );
      
      setState(() {
        _waterConsumed += ml;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: Text('Удалить "${entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await AppRepositoryProvider.diary.deleteFoodEntry(entry.id!);
      _loadData();
    }
  }

  Future<void> _editFoodEntry(FoodEntry entry) async {
    // Открыть экран редактирования грамм
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailPage(
          food: {
            'id': entry.foodId,
            'name': entry.foodName,
            'calories': entry.foodCalories,
            'proteins': entry.foodProteins,
            'fats': entry.foodFats,
            'carbs': entry.foodCarbs,
            'isCustom': entry.isCustomFood,
          },
          mealType: entry.mealType,
          date: entry.date,
          existingEntry: entry,
        ),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToFoodSearch(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchPage(
          mealType: mealType, 
          date: _selectedDate,
        ),
      ),
    ).then((_) => _loadData());
  }
}