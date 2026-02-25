// lib/presentation/pages/food/add_food_page.dart
import 'package:flutter/material.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить продукт'),
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
                        : const Text('Сохранить продукт'),
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
      
      // Имитация сохранения
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Продукт добавлен')),
      );
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