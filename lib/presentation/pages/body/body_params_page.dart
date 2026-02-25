// lib/presentation/pages/body/body_params_page.dart
import 'package:flutter/material.dart';

class BodyParamsPage extends StatefulWidget {
  const BodyParamsPage({super.key});

  @override
  State<BodyParamsPage> createState() => _BodyParamsPageState();
}

class _BodyParamsPageState extends State<BodyParamsPage> {
  final _weightController = TextEditingController();
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Параметры тела',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Введите текущие параметры тела',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Вес
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Вес (кг)',
                border: OutlineInputBorder(),
                suffixText: 'кг',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Обхват шеи
            TextField(
              controller: _neckController,
              decoration: const InputDecoration(
                labelText: 'Обхват шеи (см)',
                border: OutlineInputBorder(),
                suffixText: 'см',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Обхват талии
            TextField(
              controller: _waistController,
              decoration: const InputDecoration(
                labelText: 'Обхват талии (см)',
                border: OutlineInputBorder(),
                suffixText: 'см',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Обхват бедер
            TextField(
              controller: _hipController,
              decoration: const InputDecoration(
                labelText: 'Обхват бедер (см)',
                border: OutlineInputBorder(),
                suffixText: 'см',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMeasurements,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMeasurements() async {
    // Проверка заполнения полей
    if (_weightController.text.isEmpty ||
        _neckController.text.isEmpty ||
        _waistController.text.isEmpty ||
        _hipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Имитация сохранения
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    
    // Показываем уведомление
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Внимание'),
        content: const Text('Параметры нельзя будет редактировать после сохранения. Продолжить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Параметры сохранены')),
              );
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }
}