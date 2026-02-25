// lib/presentation/pages/food/add_recipe_page.dart
import 'package:flutter/material.dart';
import 'package:shape_up/presentation/pages/food/food_search_page.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = false;

  double _totalCalories = 0;
  double _totalProteins = 0;
  double _totalFats = 0;
  double _totalCarbs = 0;
  double _totalGrams = 0;

  void _calculateTotals() {
    _totalCalories = 0;
    _totalProteins = 0;
    _totalFats = 0;
    _totalCarbs = 0;
    _totalGrams = 0;
    
    for (var ingredient in _ingredients) {
      final grams = ingredient['grams'] as double;
      _totalCalories += (ingredient['calories'] as double) * grams / 100;
      _totalProteins += (ingredient['proteins'] as double) * grams / 100;
      _totalFats += (ingredient['fats'] as double) * grams / 100;
      _totalCarbs += (ingredient['carbs'] as double) * grams / 100;
      _totalGrams += grams;
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить рецепт'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название рецепта',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название рецепта';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ингредиенты',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_ingredients.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Добавьте ингредиенты'),
                  ),
                )
              else
                ..._ingredients.asMap().entries.map((entry) => _buildIngredientItem(entry.value, entry.key)),
              
              const Divider(height: 32),
              
              if (_ingredients.isNotEmpty) ...[
                const Text(
                  'Пищевая ценность рецепта:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildNutritionRow('Общая калорийность:', '${_totalCalories.toStringAsFixed(1)} ккал'),
                _buildNutritionRow('Общие белки:', '${_totalProteins.toStringAsFixed(1)} г'),
                _buildNutritionRow('Общие жиры:', '${_totalFats.toStringAsFixed(1)} г'),
                _buildNutritionRow('Общие углеводы:', '${_totalCarbs.toStringAsFixed(1)} г'),
                _buildNutritionRow('Общий вес:', '${_totalGrams.toStringAsFixed(1)} г'),
                const SizedBox(height: 8),
                
                if (_totalGrams > 0) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'На 100 грамм:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRow('Калории:', '${(_totalCalories * 100 / _totalGrams).toStringAsFixed(1)} ккал'),
                  _buildNutritionRow('Белки:', '${(_totalProteins * 100 / _totalGrams).toStringAsFixed(1)} г'),
                  _buildNutritionRow('Жиры:', '${(_totalFats * 100 / _totalGrams).toStringAsFixed(1)} г'),
                  _buildNutritionRow('Углеводы:', '${(_totalCarbs * 100 / _totalGrams).toStringAsFixed(1)} г'),
                ],
              ],
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || _ingredients.isEmpty ? null : _saveRecipe,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Сохранить рецепт'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientItem(Map<String, dynamic> ingredient, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(ingredient['name']),
        subtitle: Text(
          '${ingredient['grams']}г - '
          '${((ingredient['calories'] as double) * ingredient['grams'] / 100).toStringAsFixed(1)} ккал, '
          '${((ingredient['proteins'] as double) * ingredient['grams'] / 100).toStringAsFixed(1)}г б'
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              _ingredients.removeAt(index);
              _calculateTotals();
            });
          },
        ),
        onTap: () async {
          // Редактирование количества грамм
          final result = await _showGramsDialog(ingredient['grams'].toDouble());
          if (result != null) {
            setState(() {
              ingredient['grams'] = result;
              _calculateTotals();
            });
          }
        },
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<double?> _showGramsDialog(double currentGrams) async {
    final controller = TextEditingController(text: currentGrams.toString());
    
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить количество'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Граммы',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addIngredient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchPage(
          mealType: 'ingredient',
          date: DateTime.now(),
          isAddingToRecipe: true,
        ),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      final grams = await _showGramsDialog(100);
      if (grams != null) {
        setState(() {
          _ingredients.add({
            ...result,
            'grams': grams,
          });
          _calculateTotals();
        });
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Рецепт добавлен')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}