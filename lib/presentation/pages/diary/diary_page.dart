import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shape_up/presentation/pages/food/food_search_page.dart';
import 'package:shape_up/presentation/widgets/meal_section.dart';
import 'package:shape_up/presentation/widgets/water_tracker.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _selectedDate = DateTime.now();
  bool _isLocaleInitialized = false;

  // Mock data - replace with actual data from database
  final Map<String, dynamic> _nutritionData = {
    'calorieNorm': 2500,
    'calorieConsumed': 1800,
    'proteinNorm': 150,
    'proteinConsumed': 120,
    'fatNorm': 70,
    'fatConsumed': 50,
    'carbNorm': 300,
    'carbConsumed': 200,
    'waterNorm': 2500,
    'waterConsumed': 1500,
  };

  @override
  void initState() {
    super.initState();
    _initLocale();
  }

  Future<void> _initLocale() async {
    await initializeDateFormatting('ru', null);
    setState(() {
      _isLocaleInitialized = true;
    });
  }

  String _formatDate(DateTime date) {
    try {
      if (!_isLocaleInitialized) {
        // Fallback formatting without locale
        return '${date.day}.${date.month}.${date.year}';
      }

      final weekDay = DateFormat('EEEE', 'ru').format(date);
      final fullDate = DateFormat('d MMMM yyyy', 'ru').format(date);
      return '$weekDay, $fullDate';
    } catch (e) {
      // Fallback if locale fails
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  String _formatDayOfWeek(DateTime date) {
    try {
      if (!_isLocaleInitialized) {
        // Simple day names in Russian
        const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
        return days[date.weekday - 1];
      }
      return DateFormat('EEEE', 'ru').format(date);
    } catch (e) {
      return date.weekday.toString();
    }
  }

  String _formatFullDate(DateTime date) {
    try {
      if (!_isLocaleInitialized) {
        return '${date.day}.${date.month}.${date.year}';
      }
      return DateFormat('d MMMM yyyy', 'ru').format(date);
    } catch (e) {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildDateSelector(),
            ),
            SliverToBoxAdapter(
              child: _buildNutritionSummary(),
            ),
            SliverToBoxAdapter(
              child: const WaterTracker(),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Завтрак',
                entries: [], // Pass actual entries
                onAddPressed: () => _navigateToFoodSearchForBreakfast,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Обед',
                entries: [],
                onAddPressed: () => _navigateToFoodSearchForLunch,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Ужин',
                entries: [],
                onAddPressed: () => _navigateToFoodSearchForDinner,
              ),
            ),
            SliverToBoxAdapter(
              child: MealSection(
                mealType: 'Перекус',
                entries: [],
                onAddPressed: () => _navigateToFoodSearchForSnack,
              ),
            ),
          ],
        ),
      ),
    );
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
            },
          ),
          Column(
            children: [
              Text(
                _formatDayOfWeek(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                _formatFullDate(_selectedDate),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate
                    .isBefore(DateTime.now().subtract(const Duration(days: 1)))
                ? () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final calorieDiff =
        _nutritionData['calorieConsumed'] - _nutritionData['calorieNorm'];
    final calorieColor = calorieDiff > 0 ? Colors.red : Colors.green;
    final calorieIcon =
        calorieDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward;

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
                  '${_nutritionData['calorieConsumed']}',
                  '/ ${_nutritionData['calorieNorm']}',
                  calorieColor,
                  calorieIcon,
                ),
                _buildNutrientColumn(
                  'Белки',
                  '${_nutritionData['proteinConsumed']}г',
                  '/ ${_nutritionData['proteinNorm']}г',
                  _nutritionData['proteinConsumed'] >
                          _nutritionData['proteinNorm']
                      ? Colors.red
                      : Colors.green,
                  _nutritionData['proteinConsumed'] >
                          _nutritionData['proteinNorm']
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientColumn(
                  'Жиры',
                  '${_nutritionData['fatConsumed']}г',
                  '/ ${_nutritionData['fatNorm']}г',
                  _nutritionData['fatConsumed'] > _nutritionData['fatNorm']
                      ? Colors.red
                      : Colors.green,
                  _nutritionData['fatConsumed'] > _nutritionData['fatNorm']
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
                _buildNutrientColumn(
                  'Углеводы',
                  '${_nutritionData['carbConsumed']}г',
                  '/ ${_nutritionData['carbNorm']}г',
                  _nutritionData['carbConsumed'] > _nutritionData['carbNorm']
                      ? Colors.red
                      : Colors.green,
                  _nutritionData['carbConsumed'] > _nutritionData['carbNorm']
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
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
  ) {
    // Очищаем строки от лишних символов для парсинга
    double parsedValue;
    double parsedNorm;

    try {
      // Убираем 'г' и другие символы, оставляем только число
      parsedValue =
          double.parse(value.replaceAll('г', '').replaceAll('ккал', '').trim());

      // Норма может быть в формате "/ 2500" или "/2500"
      String cleanNorm = norm
          .replaceAll('/', '')
          .replaceAll('г', '')
          .replaceAll('ккал', '')
          .trim();
      parsedNorm = double.parse(cleanNorm);
    } catch (e) {
      // В случае ошибки парсинга возвращаем 0
      parsedValue = 0;
      parsedNorm = 0;
    }

    final difference = (parsedValue - parsedNorm).abs();

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
              difference.toStringAsFixed(1),
              style: TextStyle(color: diffColor, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    // Refresh data from database
    await Future.delayed(const Duration(seconds: 1));
  }

  void _navigateToFoodSearch(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchPage(mealType: mealType, date: _selectedDate),
      ),
    );
  }

  void _navigateToFoodSearchForBreakfast() {
    _navigateToFoodSearch('breakfast');
  }

  void _navigateToFoodSearchForLunch() {
    _navigateToFoodSearch('lunch');
  }

  void _navigateToFoodSearchForDinner() {
    _navigateToFoodSearch('dinner');
  }

  void _navigateToFoodSearchForSnack() {
    _navigateToFoodSearch('snack');
  }
}
