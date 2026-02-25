// lib/presentation/pages/food/food_page.dart
import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _searchController = TextEditingController();
  
  // Заглушки данных
  final List<Map<String, dynamic>> _customFoods = [
    {'id': 1, 'name': 'Протеиновый коктейль', 'calories': 120, 'proteins': 25, 'fats': 2, 'carbs': 3},
    {'id': 2, 'name': 'Овсяноблин', 'calories': 200, 'proteins': 10, 'fats': 8, 'carbs': 25},
  ];

  final List<Map<String, dynamic>> _recipes = [
    {'id': 1, 'name': 'Курица с рисом', 'calories': 350, 'proteins': 30, 'fats': 8, 'carbs': 40},
    {'id': 2, 'name': 'Омлет с овощами', 'calories': 250, 'proteins': 18, 'fats': 15, 'carbs': 10},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск продуктов и рецептов...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Мои продукты
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Мои продукты',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          // Переход на экран добавления продукта
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._customFoods.map((food) => _buildFoodItem(food)),
                  
                  const Divider(height: 32),
                  
                  // Мои рецепты
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Мои рецепты',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          // Переход на экран добавления рецепта
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._recipes.map((recipe) => _buildRecipeItem(recipe)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(food['name']),
        subtitle: Text(
          '${food['calories']} ккал, '
          '${food['proteins']}г б, ${food['fats']}г ж, ${food['carbs']}г у',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            // Удаление продукта
          },
        ),
        onTap: () {
          // Редактирование продукта
        },
      ),
    );
  }

  Widget _buildRecipeItem(Map<String, dynamic> recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(recipe['name']),
        subtitle: Text(
          '${recipe['calories']} ккал/100г, '
          '${recipe['proteins']}г б, ${recipe['fats']}г ж, ${recipe['carbs']}г у',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            // Удаление рецепта
          },
        ),
        onTap: () {
          // Редактирование рецепта
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}