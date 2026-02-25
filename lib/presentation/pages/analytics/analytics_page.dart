import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/usecases/calculate_nutrition.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedType = 'weight';
  DateTime? _selectedMonth;
  DateTime? _startPhotoDate;
  DateTime? _endPhotoDate;
  
  List<DateTime> _availablePhotoDates = [];
  Map<String, List<Map<String, dynamic>>> _chartData = {};
  bool _isLoading = false;
  
  final _calculator = CalculateNutrition();

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;

      // Загружаем доступные даты фото
      _availablePhotoDates = await AppRepositoryProvider.photo.getAvailablePhotoDates(
        authState.user!.id,
      );
      
      // Загружаем данные для графиков
      if (_selectedType != 'photos') {
        await _loadChartData();
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChartData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null || _selectedMonth == null) return;

    final data = await AppRepositoryProvider.body.getMeasurementsForChart(
      authState.user!.id,
      _selectedMonth!.year,
      _selectedMonth!.month,
    );
    
    setState(() {
      _chartData = data;
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
              'Аналитика',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Выбор типа аналитики
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип аналитики',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'weight', child: Text('Изменение веса')),
                DropdownMenuItem(value: 'neck', child: Text('Обхват шеи')),
                DropdownMenuItem(value: 'waist', child: Text('Обхват талии')),
                DropdownMenuItem(value: 'hip', child: Text('Обхват бедер')),
                DropdownMenuItem(value: 'bodyFat', child: Text('% жира')),
                DropdownMenuItem(value: 'photos', child: Text('Фото до/после')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                _loadData();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Выбор месяца для графиков
            if (_selectedType != 'photos') ...[
              ListTile(
                title: const Text('Выберите месяц'),
                subtitle: Text(
                  _selectedMonth != null
                      ? DateFormat('MMMM yyyy', 'ru').format(_selectedMonth!)
                      : 'Не выбран',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectMonth,
              ),
              const SizedBox(height: 16),
            ],
            
            // Выбор дат для фото
            if (_selectedType == 'photos') ...[
              _buildPhotoDateSelector(),
            ],
            
            const SizedBox(height: 24),
            
            // Отображение контента
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoDateSelector() {
    if (_availablePhotoDates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Нет доступных фотографий'),
        ),
      );
    }

    return Column(
      children: [
        DropdownButtonFormField<DateTime>(
          value: _startPhotoDate,
          hint: const Text('Выберите первую дату'),
          decoration: const InputDecoration(labelText: 'Дата "до"'),
          items: _availablePhotoDates.map((date) {
            return DropdownMenuItem(
              value: date,
              child: Text(DateFormat('dd.MM.yyyy').format(date)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _startPhotoDate = value;
              _endPhotoDate = null;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<DateTime>(
          value: _endPhotoDate,
          hint: const Text('Выберите вторую дату'),
          decoration: const InputDecoration(labelText: 'Дата "после"'),
          items: _availablePhotoDates
              .where((date) => _startPhotoDate == null || date.isAfter(_startPhotoDate!))
              .map((date) {
                return DropdownMenuItem(
                  value: date,
                  child: Text(DateFormat('dd.MM.yyyy').format(date)),
                );
              })
              .toList(),
          onChanged: (value) {
            setState(() {
              _endPhotoDate = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_selectedType == 'photos') {
      return _buildPhotoComparison();
    } else {
      return _buildChart();
    }
  }

  Widget _buildChart() {
    final data = _chartData[_selectedType] ?? [];
    
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Нет данных за выбранный месяц'),
        ),
      );
    }

    String title = '';
    String unit = '';
    Color color = Colors.blue;

    switch (_selectedType) {
      case 'weight':
        title = 'Изменение веса';
        unit = 'кг';
        color = Colors.green;
        break;
      case 'neck':
        title = 'Обхват шеи';
        unit = 'см';
        color = Colors.orange;
        break;
      case 'waist':
        title = 'Обхват талии';
        unit = 'см';
        color = Colors.red;
        break;
      case 'hip':
        title = 'Обхват бедер';
        unit = 'см';
        color = Colors.purple;
        break;
      case 'bodyFat':
        title = 'Процент жира';
        unit = '%';
        color = Colors.indigo;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text('${date.day}');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()} $unit');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data.map((point) {
                    return FlSpot(
                      point['date'].millisecondsSinceEpoch.toDouble(),
                      point['value'].toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_selectedType == 'bodyFat') ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'О проценте жира',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Процент жира в организме - это доля жировой ткани от общей массы тела. '
                    'Здоровые показатели: для мужчин 10-20%, для женщин 18-28%. '
                    'Слишком низкий процент жира может быть опасен для здоровья, '
                    'слишком высокий - повышает риск различных заболеваний.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoComparison() {
    if (_startPhotoDate == null || _endPhotoDate == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Выберите даты для сравнения'),
        ),
      );
    }

    return FutureBuilder(
      future: Future.wait([
        AppRepositoryProvider.photo.getPhotoProgressForDate(
          context.read<AuthBloc>().state.user!.id,
          _startPhotoDate!,
        ),
        AppRepositoryProvider.photo.getPhotoProgressForDate(
          context.read<AuthBloc>().state.user!.id,
          _endPhotoDate!,
        ),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final before = snapshot.data![0];
        final after = snapshot.data![1];

        if (before == null || after == null) {
          return const Center(child: Text('Фото не найдены'));
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(_startPhotoDate!),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(_endPhotoDate!),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPhotoRow('Спереди', before.frontPhoto, after.frontPhoto),
            _buildPhotoRow('Сзади', before.backPhoto, after.backPhoto),
            _buildPhotoRow('Левый бок', before.leftSidePhoto, after.leftSidePhoto),
            _buildPhotoRow('Правый бок', before.rightSidePhoto, after.rightSidePhoto),
          ],
        );
      },
    );
  }

  Widget _buildPhotoRow(String label, String? beforePath, String? afterPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildPhoto(beforePath),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPhoto(afterPath),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String? path) {
    if (path == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _loadChartData();
    }
  }
}