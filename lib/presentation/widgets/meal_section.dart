import 'package:flutter/material.dart';
import 'package:shape_up/domain/entities/food_entry.dart';

class MealSection extends StatelessWidget {
  final String mealType;
  final List<FoodEntry> entries;
  final Map<String, double> mealSummary;
  final VoidCallback onAddPressed;
  final Function(FoodEntry) onDeleteEntry;
  final Function(FoodEntry) onEditEntry;

  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.mealSummary,
    required this.onAddPressed,
    required this.onDeleteEntry,
    required this.onEditEntry,
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
                Row(
                  children: [
                    if (entries.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${mealSummary['grams']?.toInt()}г • '
                          '${mealSummary['calories']?.toInt()} ккал',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onAddPressed,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Нет добавленных продуктов',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...entries.map((entry) => _buildFoodItem(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(FoodEntry entry) {
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
                  entry.foodName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => onDeleteEntry(entry),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${entry.grams.toStringAsFixed(0)}г'),
              Text(
                '${entry.calories.toStringAsFixed(0)} ккал, '
                '${entry.proteins.toStringAsFixed(1)}г б, '
                '${entry.fats.toStringAsFixed(1)}г ж, '
                '${entry.carbs.toStringAsFixed(1)}г у',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}