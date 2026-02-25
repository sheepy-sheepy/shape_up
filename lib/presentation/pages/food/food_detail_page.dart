import 'package:flutter/material.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> food;
  final String mealType;
  final DateTime date;

  const FoodDetailPage({
    super.key,
    required this.food,
    required this.mealType,
    required this.date,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final _gramsController = TextEditingController(text: '100');
  double _calories = 0;
  double _proteins = 0;
  double _fats = 0;
  double _carbs = 0;

  @override
  void initState() {
    super.initState();
    _updateNutrition();
    _gramsController.addListener(_updateNutrition);
  }

  void _updateNutrition() {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    setState(() {
      _calories = (widget.food['calories'] * grams / 100).roundToDouble();
      _proteins = (widget.food['proteins'] * grams / 100).roundToDouble();
      _fats = (widget.food['fats'] * grams / 100).roundToDouble();
      _carbs = (widget.food['carbs'] * grams / 100).roundToDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _gramsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Количество грамм',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionItem('Калории', '$_calories ккал'),
                        _buildNutritionItem('Белки', '$_proteins г'),
                        _buildNutritionItem('Жиры', '$_fats г'),
                        _buildNutritionItem('Углеводы', '$_carbs г'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addFoodEntry,
                child: const Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  void _addFoodEntry() {
    // Save to database
    Navigator.pop(context); // Return to search
    Navigator.pop(context); // Return to diary
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }
}