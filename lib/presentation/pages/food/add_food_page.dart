import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/food.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddFoodPage extends StatefulWidget {
  final Food? food;

  const AddFoodPage({super.key, this.food});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.food != null) {
      _isEditing = true;
      _nameController.text = widget.food!.name;
      _caloriesController.text = widget.food!.calories.toString();
      _proteinsController.text = widget.food!.proteins.toString();
      _fatsController.text = widget.food!.fats.toString();
      _carbsController.text = widget.food!.carbs.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать продукт' : 'Добавить продукт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название продукта',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название продукта';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Калории (на 100г)',
                    border: OutlineInputBorder(),
                    suffixText: 'ккал',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите калорийность';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите число';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _proteinsController,
                  decoration: const InputDecoration(
                    labelText: 'Белки (на 100г)',
                    border: OutlineInputBorder(),
                    suffixText: 'г',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите количество белков';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите число';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _fatsController,
                  decoration: const InputDecoration(
                    labelText: 'Жиры (на 100г)',
                    border: OutlineInputBorder(),
                    suffixText: 'г',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите количество жиров';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите число';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Углеводы (на 100г)',
                    border: OutlineInputBorder(),
                    suffixText: 'г',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите количество углеводов';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите число';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveFood,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(_isEditing ? 'Сохранить изменения' : 'Сохранить продукт'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveFood() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final authState = context.read<AuthBloc>().state;
        if (authState.user == null) throw Exception('User not found');
        
        final food = Food(
          id: widget.food?.id,
          name: _nameController.text,
          calories: double.parse(_caloriesController.text),
          proteins: double.parse(_proteinsController.text),
          fats: double.parse(_fatsController.text),
          carbs: double.parse(_carbsController.text),
          isCustom: true,
          userId: authState.user!.id,
          createdAt: DateTime.now(),
        );
        
        if (_isEditing) {
          await AppRepositoryProvider.food.updateCustomFood(food);
        } else {
          await AppRepositoryProvider.food.addCustomFood(food);
        }
        
        if (!mounted) return;
        
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Продукт обновлен' 
                : 'Продукт добавлен'),
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
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }
}