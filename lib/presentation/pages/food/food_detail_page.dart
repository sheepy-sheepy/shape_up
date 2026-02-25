import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/food_entry.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> food;
  final String mealType;
  final DateTime date;
  final FoodEntry? existingEntry;

  const FoodDetailPage({
    super.key,
    required this.food,
    required this.mealType,
    required this.date,
    this.existingEntry,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final _gramsController = TextEditingController();
  double _calories = 0;
  double _proteins = 0;
  double _fats = 0;
  double _carbs = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _gramsController.text = widget.existingEntry!.grams.toString();
    } else {
      _gramsController.text = '100';
    }
    _gramsController.addListener(_updateNutrition);
    _updateNutrition();
  }

  void _updateNutrition() {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    setState(() {
      _calories = (widget.food['calories'] * grams / 100);
      _proteins = (widget.food['proteins'] * grams / 100);
      _fats = (widget.food['fats'] * grams / 100);
      _carbs = (widget.food['carbs'] * grams / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать' : widget.food['name']),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Поле ввода грамм
                    TextField(
                      controller: _gramsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Количество грамм',
                        border: OutlineInputBorder(),
                        suffixText: 'г',
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Показатели КБЖУ
                    const Text(
                      'Пищевая ценность:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildNutritionRow('Калории', '${_calories.toStringAsFixed(1)} ккал'),
                    _buildNutritionRow('Белки', '${_proteins.toStringAsFixed(1)} г'),
                    _buildNutritionRow('Жиры', '${_fats.toStringAsFixed(1)} г'),
                    _buildNutritionRow('Углеводы', '${_carbs.toStringAsFixed(1)} г'),
                    
                    const SizedBox(height: 8),
                    Text(
                      'На 100г: ${widget.food['calories']} ккал, '
                      '${widget.food['proteins']}г б, '
                      '${widget.food['fats']}г ж, '
                      '${widget.food['carbs']}г у',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Кнопки
            Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _deleteEntry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Удалить'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEntry,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(isEditing ? 'Сохранить' : 'Добавить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEntry() async {
    final grams = double.tryParse(_gramsController.text);
    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректное количество грамм')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) throw Exception('User not found');

      final entry = FoodEntry(
        id: widget.existingEntry?.id,
        userId: authState.user!.id,
        date: widget.date,
        mealType: widget.mealType,
        foodId: widget.food['id'],
        grams: grams,
        isCustomFood: widget.food['isCustom'] ?? false,
        isRecipe: widget.food['isRecipe'] ?? false,
        recipeId: widget.food['recipeId'],
        createdAt: DateTime.now(),
        foodName: widget.food['name'],
        foodCalories: widget.food['calories'],
        foodProteins: widget.food['proteins'],
        foodFats: widget.food['fats'],
        foodCarbs: widget.food['carbs'],
      );

      if (widget.existingEntry != null) {
        await AppRepositoryProvider.diary.updateFoodEntry(entry);
      } else {
        await AppRepositoryProvider.diary.addFoodEntry(entry);
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingEntry != null
              ? 'Запись обновлена'
              : 'Продукт добавлен в ${_getMealName(widget.mealType)}'),
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

  Future<void> _deleteEntry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: const Text('Удалить эту запись?'),
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
      await AppRepositoryProvider.diary.deleteFoodEntry(widget.existingEntry!.id!);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запись удалена'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _getMealName(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return 'завтрак';
      case 'lunch':
        return 'обед';
      case 'dinner':
        return 'ужин';
      case 'snack':
        return 'перекус';
      default:
        return mealType;
    }
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }
}