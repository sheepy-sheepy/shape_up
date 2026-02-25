import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/body_measurement.dart';
import 'package:shape_up/domain/entities/user.dart';
import 'package:shape_up/domain/usecases/calculate_nutrition.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final _calculator = CalculateNutrition();

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
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Пол',
                  border: OutlineInputBorder(),
                ),
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
                value: _selectedGoal,
                decoration: const InputDecoration(
                  labelText: 'Цель',
                  border: OutlineInputBorder(),
                ),
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
                value: _selectedActivity,
                decoration: const InputDecoration(
                  labelText: 'Уровень активности',
                  border: OutlineInputBorder(),
                ),
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

      try {
        final authState = context.read<AuthBloc>().state;
        if (authState.user == null) throw Exception('User not found');

        final userId = authState.user!.id;

        // Сначала проверяем, существует ли пользователь в локальной БД
        final existingUser =
            await AppRepositoryProvider.auth.getUserById(userId);

        final updatedUser = User(
          id: userId,
          email: authState.user!.email,
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          neckCircumference: double.parse(_neckController.text),
          waistCircumference: double.parse(_waistController.text),
          hipCircumference: double.parse(_hipController.text),
          gender: _selectedGender,
          goal: _selectedGoal,
          activityLevel: _selectedActivity,
          birthDate: _birthDate,
          createdAt: existingUser?.createdAt ?? DateTime.now(),
          hasCompletedInitialParams: true,
        );

        if (existingUser == null) {
          // Создаем нового пользователя
          await AppRepositoryProvider.auth.createUser(updatedUser);
        } else {
          // Обновляем существующего
          await AppRepositoryProvider.auth.updateUser(updatedUser);
        }

        await AppRepositoryProvider.auth.setInitialParamsCompleted(userId);

        // Создаем первую запись измерений
        await AppRepositoryProvider.body.addMeasurement(
          BodyMeasurement(
            userId: userId,
            date: DateTime.now(),
            weight: double.parse(_weightController.text),
            neckCircumference: double.parse(_neckController.text),
            waistCircumference: double.parse(_waistController.text),
            hipCircumference: double.parse(_hipController.text),
            bodyFatPercentage: _calculator.calculateBodyFatPercentage(
              waist: double.parse(_waistController.text),
              neck: double.parse(_neckController.text),
              height: double.parse(_heightController.text),
              gender: _selectedGender,
              hip: double.parse(_hipController.text),
            ),
            createdAt: DateTime.now(),
          ),
        );

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text(
                'Параметры сохранены. Теперь вы можете пользоваться приложением.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/main');
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
