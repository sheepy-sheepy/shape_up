// lib/presentation/pages/onboarding/initial_params_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InitialParamsPage extends StatefulWidget {
  const InitialParamsPage({super.key});

  @override
  State<InitialParamsPage> createState() => _InitialParamsPageState();
}

class _InitialParamsPageState extends State<InitialParamsPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();

  String _selectedGender = 'Мужской';
  String _selectedGoal = 'Похудение';
  String _selectedActivity = 'Сидячий образ жизни';
  DateTime? _birthDate;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод параметров'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Заполните ваши параметры',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Рост
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Рост (см)',
                  border: OutlineInputBorder(),
                  suffixText: 'см',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите рост';
                  final height = int.tryParse(value);
                  if (height == null || height < 140 || height > 220) {
                    return 'Рост должен быть от 140 до 220 см';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Вес
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Вес (кг)',
                  border: OutlineInputBorder(),
                  suffixText: 'кг',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите вес';
                  final weight = int.tryParse(value);
                  if (weight == null || weight < 30 || weight > 200) {
                    return 'Вес должен быть от 30 до 200 кг';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Обхват шеи
              TextFormField(
                controller: _neckController,
                decoration: const InputDecoration(
                  labelText: 'Обхват шеи (см)',
                  border: OutlineInputBorder(),
                  suffixText: 'см',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Введите обхват шеи';
                  final neck = int.tryParse(value);
                  if (neck == null || neck < 20 || neck > 100) {
                    return 'Обхват шеи должен быть от 20 до 100 см';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Обхват талии
              TextFormField(
                controller: _waistController,
                decoration: const InputDecoration(
                  labelText: 'Обхват талии (см)',
                  border: OutlineInputBorder(),
                  suffixText: 'см',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Введите обхват талии';
                  final waist = int.tryParse(value);
                  if (waist == null || waist < 40 || waist > 200) {
                    return 'Обхват талии должен быть от 40 до 200 см';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Обхват бедер
              TextFormField(
                controller: _hipController,
                decoration: const InputDecoration(
                  labelText: 'Обхват бедер (см)',
                  border: OutlineInputBorder(),
                  suffixText: 'см',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Введите обхват бедер';
                  final hip = int.tryParse(value);
                  if (hip == null || hip < 40 || hip > 200) {
                    return 'Обхват бедер должен быть от 40 до 200 см';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Пол
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Пол',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                  DropdownMenuItem(value: 'Женский', child: Text('Женский')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Дата рождения
              ListTile(
                title: const Text('Дата рождения'),
                subtitle: Text(
                  _birthDate != null
                      ? DateFormat('dd.MM.yyyy').format(_birthDate!)
                      : 'Выберите дату',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectBirthDate,
              ),
              const SizedBox(height: 16),

              // Цель
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Цель',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGoal,
                items: const [
                  DropdownMenuItem(
                      value: 'Похудение', child: Text('Похудение')),
                  DropdownMenuItem(
                      value: 'Поддержание', child: Text('Поддержание')),
                  DropdownMenuItem(
                      value: 'Набор массы', child: Text('Набор массы')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Уровень активности
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Уровень активности',
                  border: OutlineInputBorder(),
                ),
                value: _selectedActivity,
                items: const [
                  DropdownMenuItem(
                      value: 'Сидячий образ жизни',
                      child: Text('Сидячий образ жизни')),
                  DropdownMenuItem(
                      value: 'Тренировки 1-3 раза в неделю',
                      child: Text('Тренировки 1-3 раза в неделю')),
                  DropdownMenuItem(
                      value: 'Тренировки 3-5 раз в неделю',
                      child: Text('Тренировки 3-5 раз в неделю')),
                  DropdownMenuItem(
                      value: 'Тренировки 6-7 раз в неделю',
                      child: Text('Тренировки 6-7 раз в неделю')),
                  DropdownMenuItem(
                      value: 'Профессиональный спорт или физическая работа',
                      child: Text('Профессиональный спорт')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveParams,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveParams() async {
    if (_formKey.currentState!.validate() && _birthDate != null) {
      setState(() => _isLoading = true);

      // Имитация сохранения
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text(
                'Параметры нельзя будет изменить после сохранения. Продолжить?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text('Подтвердить'),
              ),
            ],
          ),
        );
      }
    } else if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите дату рождения')),
      );
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }
}
