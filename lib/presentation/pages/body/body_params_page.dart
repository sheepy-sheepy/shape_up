import 'package:flutter/material.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/body_measurement.dart';
import 'package:shape_up/domain/entities/user.dart';
import 'package:shape_up/domain/usecases/calculate_nutrition.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  bool _hasTodayMeasurement = false;
  final _calculator = CalculateNutrition();

  @override
  void initState() {
    super.initState();
    _checkTodayMeasurement();
  }

  Future<void> _checkTodayMeasurement() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) return;
    
    final hasMeasurement = await AppRepositoryProvider.body.hasMeasurementForDate(
      authState.user!.id,
      DateTime.now(),
    );
    
    setState(() {
      _hasTodayMeasurement = hasMeasurement;
    });
  }

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
            
            if (_hasTodayMeasurement) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Вы уже вводили параметры сегодня. Следующее обновление доступно завтра.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Вес
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Вес (кг)',
                border: OutlineInputBorder(),
                suffixText: 'кг',
              ),
              keyboardType: TextInputType.number,
              enabled: !_hasTodayMeasurement,
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
              enabled: !_hasTodayMeasurement,
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
              enabled: !_hasTodayMeasurement,
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
              enabled: !_hasTodayMeasurement,
            ),
            const SizedBox(height: 24),
            
            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hasTodayMeasurement || _isLoading ? null : _saveMeasurements,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasTodayMeasurement ? Colors.grey : null,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_hasTodayMeasurement ? 'Уже добавлено сегодня' : 'Сохранить'),
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
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) throw Exception('User not found');
      
      final userId = authState.user!.id;
      final today = DateTime.now();
      final weight = double.parse(_weightController.text);
      final neck = double.parse(_neckController.text);
      final waist = double.parse(_waistController.text);
      final hip = double.parse(_hipController.text);
      
      // Расчет % жира
      final bodyFat = _calculator.calculateBodyFatPercentage(
        waist: waist,
        neck: neck,
        height: authState.user!.height ?? 0,
        gender: authState.user!.gender ?? 'Мужской',
        hip: hip,
      );
      
      // Сохраняем измерение
      await AppRepositoryProvider.body.addMeasurement(
        BodyMeasurement(
          userId: userId,
          date: today,
          weight: weight,
          neckCircumference: neck,
          waistCircumference: waist,
          hipCircumference: hip,
          bodyFatPercentage: bodyFat,
          createdAt: DateTime.now(),
        ),
      );
      
      // Обновляем текущий вес пользователя
      final updatedUser = User(
        id: userId,
        email: authState.user!.email,
        name: authState.user!.name,
        birthDate: authState.user!.birthDate,
        gender: authState.user!.gender,
        height: authState.user!.height,
        weight: weight,
        neckCircumference: neck,
        waistCircumference: waist,
        hipCircumference: hip,
        goal: authState.user!.goal,
        activityLevel: authState.user!.activityLevel,
        calorieDeficit: authState.user!.calorieDeficit,
        calorieSurplus: authState.user!.calorieSurplus,
        createdAt: authState.user!.createdAt,
        hasCompletedInitialParams: true,
      );
      
      await AppRepositoryProvider.auth.updateUser(updatedUser);
      
      if (!mounted) return;
      
      // Показываем уведомление
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Внимание'),
          content: const Text('Параметры сохранены. Следующее обновление доступно завтра.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hasTodayMeasurement = true;
                });
              },
              child: const Text('OK'),
            ),
          ],
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

  @override
  void dispose() {
    _weightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }
}