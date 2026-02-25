// lib/presentation/widgets/meal_section.dart
import 'package:flutter/material.dart';

class MealSection extends StatelessWidget {
  final String mealType;
  final List<Map<String, dynamic>> entries;
  final VoidCallback onAddPressed;

  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAddPressed,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет добавленных продуктов'),
                ),
              )
            else
              ...entries.map((entry) => _buildFoodItem(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  // Удалить продукт
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${entry['grams']}г'),
              Text(
                '${entry['calories']} ккал, '
                '${entry['proteins']}г б, '
                '${entry['fats']}г ж, '
                '${entry['carbs']}г у',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}