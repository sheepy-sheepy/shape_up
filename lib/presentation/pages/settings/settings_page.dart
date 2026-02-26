// lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shape_up/data/datasources/remote/supabase_service.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/auth/login_page.dart';
import 'package:shape_up/domain/usecases/calculate_nutrition.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedGoal = 'Похудение';
  int _deficit = 300;
  int _surplus = 500;
  DateTime? _birthDate;
  String _gender = 'Мужской';
  String _activityLevel = 'Сидячий образ жизни';
  final _heightController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // Данные для отображения BMR/DCI
  double _bmr = 0;
  double _dci = 0;
  double _calorieNorm = 0;
  final CalculateNutrition _calculator = CalculateNutrition();

  @override
  void initState() {
    super.initState();
    _calculateNorms();
  }

  void _calculateNorms() {
    // Примерные данные - в реальном приложении берутся из профиля пользователя
    const double weight = 70;
    const double height = 175;
    const int age = 30;

    _bmr = _calculator.calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: _gender,
    );

    final activityMultiplier =
        _calculator.getActivityMultiplier(_activityLevel);
    _dci = _bmr * activityMultiplier;

    switch (_selectedGoal) {
      case 'Похудение':
        _calorieNorm = _dci - _deficit;
        break;
      case 'Набор массы':
        _calorieNorm = _dci + _surplus;
        break;
      default:
        _calorieNorm = _dci;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о калориях
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ваши нормы',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('BMR (базальный метаболизм):',
                        '${_bmr.toStringAsFixed(0)} ккал'),
                    _buildInfoRow('DCI (с учетом активности):',
                        '${_dci.toStringAsFixed(0)} ккал'),
                    _buildInfoRow('Норма калорий:',
                        '${_calorieNorm.toStringAsFixed(0)} ккал'),
                    const SizedBox(height: 8),
                    const Text(
                      'BMR - количество калорий, необходимое для поддержания жизнедеятельности в покое\n'
                      'DCI - дневная норма калорий с учетом физической активности',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Цель и калории',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGoalSection(),
            const Divider(height: 32),

            const Text(
              'Персональные данные',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPersonalDataSection(),
            const Divider(height: 32),

            const Text(
              'Смена пароля',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPasswordSection(),
            const Divider(height: 32),

            const SizedBox(height: 16),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGoalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Цель'),
              value: _selectedGoal,
              items: const [
                DropdownMenuItem(value: 'Похудение', child: Text('Похудение')),
                DropdownMenuItem(
                    value: 'Поддержание', child: Text('Поддержание')),
                DropdownMenuItem(
                    value: 'Набор массы', child: Text('Набор массы')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGoal = value!;
                  _calculateNorms();
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedGoal == 'Похудение') ...[
              Text('Дефицит калорий: $_deficit ккал'),
              Slider(
                value: _deficit.toDouble(),
                min: 200,
                max: 500,
                divisions: 6,
                label: '$_deficit ккал',
                onChanged: (value) {
                  setState(() {
                    _deficit = value.round();
                    _calculateNorms();
                  });
                },
              ),
            ],
            if (_selectedGoal == 'Набор массы') ...[
              Text('Профицит калорий: $_surplus ккал'),
              Slider(
                value: _surplus.toDouble(),
                min: 200,
                max: 1000,
                divisions: 8,
                label: '$_surplus ккал',
                onChanged: (value) {
                  setState(() {
                    _surplus = value.round();
                    _calculateNorms();
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Дата рождения'),
              subtitle: Text(_birthDate != null
                  ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'
                  : 'Не выбрана'),
              onTap: _selectBirthDate,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Пол'),
              value: _gender,
              items: const [
                DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                DropdownMenuItem(value: 'Женский', child: Text('Женский')),
              ],
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                  _calculateNorms();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Уровень активности'),
              value: _activityLevel,
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
                  _activityLevel = value!;
                  _calculateNorms();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Рост (см)',
                suffixText: 'см',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _calculateNorms();
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePersonalData,
                child: const Text('Сохранить изменения'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Старый пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Сменить пароль'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Выйти из аккаунта'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmDeleteAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить аккаунт'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _calculateNorms();
      });
    }
  }

  void _savePersonalData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успешно'),
        content: const Text('Данные сохранены'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль должен быть не менее 6 символов')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Успешно'),
        content: const Text('Пароль успешно изменен'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _oldPasswordController.clear();
    _newPasswordController.clear();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Закрываем диалог

              // Выходим из аккаунта
              context.read<AuthBloc>().add(AuthLogout());

              // Переходим на экран входа
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление аккаунта'),
        content: const Text(
            'Вы уверены? Это действие необратимо. Все ваши данные будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: _deleteAccount,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить навсегда'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Аккаунт удален')),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
