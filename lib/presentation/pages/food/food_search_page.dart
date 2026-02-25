// lib/presentation/pages/food/food_search_page.dart
import 'package:flutter/material.dart';
import 'package:shape_up/presentation/pages/food/food_detail_page.dart';

class FoodSearchPage extends StatefulWidget {
  final String mealType;
  final DateTime date;
  final bool isAddingToRecipe;

  const FoodSearchPage({
    super.key,
    required this.mealType,
    required this.date,
    this.isAddingToRecipe = false,
  });

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _searchController = TextEditingController();
  
  // Mock data - replace with actual data from database
  final List<Map<String, dynamic>> _foods = [
    {'id': 1, 'name': 'Антилопа', 'calories': 114.0, 'proteins': 22.38, 'fats': 2.03, 'carbs': 0.0, 'isCustom': false},
    {'id': 2, 'name': 'Говядина', 'calories': 250.0, 'proteins': 26.0, 'fats': 15.0, 'carbs': 0.0, 'isCustom': false},
    {'id': 3, 'name': 'Куриная грудка', 'calories': 165.0, 'proteins': 31.0, 'fats': 3.6, 'carbs': 0.0, 'isCustom': false},
    {'id': 4, 'name': 'Рис', 'calories': 130.0, 'proteins': 2.7, 'fats': 0.3, 'carbs': 28.0, 'isCustom': false},
    {'id': 5, 'name': 'Гречка', 'calories': 343.0, 'proteins': 13.0, 'fats': 3.4, 'carbs': 72.0, 'isCustom': false},
  ];

  List<Map<String, dynamic>> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    _filteredFoods = _foods;
    _searchController.addListener(_filterFoods);
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoods = _foods.where((food) {
        return food['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск продуктов'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFoods.length,
              itemBuilder: (context, index) {
                final food = _filteredFoods[index];
                return ListTile(
                  title: Text(food['name']),
                  subtitle: Text(
                    'КБЖУ на 100г: ${food['calories']} ккал, '
                    '${food['proteins']}г б, ${food['fats']}г ж, ${food['carbs']}г у',
                  ),
                  onTap: () {
                    if (widget.isAddingToRecipe) {
                      Navigator.pop(context, food);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailPage(
                            food: food,
                            mealType: widget.mealType,
                            date: widget.date,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}