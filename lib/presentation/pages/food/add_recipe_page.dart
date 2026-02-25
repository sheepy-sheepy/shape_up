import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/food.dart';
import 'package:shape_up/domain/entities/recipe.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/food/food_search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddRecipePage extends StatefulWidget {
  final Recipe? recipe;

  const AddRecipePage({super.key, this.recipe});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  List<RecipeIngredient> _ingredients = [];
  bool _isLoading = false;
  bool _isEditing = false;

  double _totalCalories = 0;
  double _totalProteins = 0;
  double _totalFats = 0;
  double _totalCarbs = 0;
  double _totalGrams = 0;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _isEditing = true;
      _nameController.text = widget.recipe!.name;
      _ingredients = List.from(widget.recipe!.ingredients);
      _calculateTotals();
    }
  }

  void _calculateTotals() {
    _totalCalories = 0;
    _totalProteins = 0;
    _totalFats = 0;
    _totalCarbs = 0;
    _totalGrams = 0;
    
    for (var ingredient in _ingredients) {
      _totalCalories += ingredient.calories;
      _totalProteins += ingredient.proteins;
      _totalFats += ingredient.fats;
      _totalCarbs += ingredient.carbs;
      _totalGrams += ingredient.grams;
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать рецепт' : 'Добавить рецепт'),
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
                    child: Text('Добавьте ингредиенты (минимум 2)'),
                  ),
                )
              else
                ..._ingredients.asMap().entries.map((entry) => 
                  _buildIngredientItem(entry.value, entry.key)
                ),
              
              if (_ingredients.isNotEmpty) ...[
                const Divider(height: 32),
                
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
                  onPressed: _isLoading || _ingredients.length < 2 ? null : _saveRecipe,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isEditing ? 'Сохранить изменения' : 'Сохранить рецепт'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientItem(RecipeIngredient ingredient, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(ingredient.foodName),
        subtitle: Text(
          '${ingredient.grams}г - '
          '${ingredient.calories.toStringAsFixed(1)} ккал, '
          '${ingredient.proteins.toStringAsFixed(1)}г б',
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
        onTap: () => _editIngredient(ingredient, index),
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

  Future<void> _addIngredient() async {
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
        final food = result['food'] as Food;
        final ingredient = RecipeIngredient(
          recipeId: widget.recipe?.id ?? 0,
          foodId: food.id!,
          grams: grams,
          isCustomFood: food.isCustom,
          foodName: food.name,
          foodCalories: food.calories,
          foodProteins: food.proteins,
          foodFats: food.fats,
          foodCarbs: food.carbs,
        );
        
        setState(() {
          _ingredients.add(ingredient);
          _calculateTotals();
        });
      }
    }
  }

  Future<void> _editIngredient(RecipeIngredient ingredient, int index) async {
    final grams = await _showGramsDialog(ingredient.grams);
    if (grams != null) {
      setState(() {
        _ingredients[index] = RecipeIngredient(
          id: ingredient.id,
          recipeId: ingredient.recipeId,
          foodId: ingredient.foodId,
          grams: grams,
          isCustomFood: ingredient.isCustomFood,
          foodName: ingredient.foodName,
          foodCalories: ingredient.foodCalories,
          foodProteins: ingredient.foodProteins,
          foodFats: ingredient.foodFats,
          foodCarbs: ingredient.foodCarbs,
        );
        _calculateTotals();
      });
    }
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

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final authState = context.read<AuthBloc>().state;
        if (authState.user == null) throw Exception('User not found');
        
        final recipe = Recipe(
          id: widget.recipe?.id,
          name: _nameController.text,
          userId: authState.user!.id,
          ingredients: _ingredients,
          totalCalories: _totalCalories,
          totalProteins: _totalProteins,
          totalFats: _totalFats,
          totalCarbs: _totalCarbs,
          totalGrams: _totalGrams,
          createdAt: DateTime.now(),
        );
        
        if (_isEditing) {
          await AppRepositoryProvider.food.updateRecipe(recipe);
        } else {
          await AppRepositoryProvider.food.addRecipe(recipe);
        }
        
        if (!mounted) return;
        
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Рецепт обновлен' 
                : 'Рецепт добавлен'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}